import os
import mysql.connector
from mysql.connector import errorcode
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

load_dotenv()

app = FastAPI(title="Loja de Plantas")


def conectar():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST", "localhost"),
        port=int(os.getenv("DB_PORT", "3306")),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD", ""),
        database=os.getenv("DB_NAME", "loja_de_plantas"),
    )


def consultar(sql, valores=()):
    con = conectar()
    cur = con.cursor(dictionary=True)
    try:
        cur.execute(sql, valores)
        return cur.fetchall()
    finally:
        cur.close()
        con.close()


def executar(sql, valores=()):
    con = conectar()
    cur = con.cursor()
    try:
        cur.execute(sql, valores)
        con.commit()
        return cur.lastrowid
    except mysql.connector.Error:
        con.rollback()
        raise
    finally:
        cur.close()
        con.close()


SELECT_PRODUTO = """
    SELECT Prod_ID AS id,
           Prod_Nome AS nome,
           Prod_Tipo AS tipo,
           Prod_preco AS preco,
           Prod_qnt AS quantidade,
           Forn_ID_fk AS fornecedor_cnpj
    FROM produto
"""


def buscar_produto(produto_id):
    linhas = consultar(SELECT_PRODUTO + " WHERE Prod_ID = %s", (produto_id,))
    if len(linhas) == 0:
        return None
    return linhas[0]


class ProdutoEntrada(BaseModel):
    nome: str = Field(min_length=1, examples=["Samambaia"])
    tipo: str = Field(min_length=1, examples=["Planta"])
    preco: float = Field(gt=0, le=99999.99, examples=[45.0])
    quantidade: int = Field(ge=0, examples=[10])
    fornecedor_cnpj: str = Field(min_length=14, max_length=14, examples=["12345678000199"])


class Produto(ProdutoEntrada):
    id: int


@app.get("/produtos", response_model=list[Produto], tags=["Produtos"])
def listar_produtos():
    return consultar(SELECT_PRODUTO + " ORDER BY Prod_ID")


@app.get("/produtos/{produto_id}", response_model=Produto, tags=["Produtos"])
def obter_produto(produto_id: int):
    produto = buscar_produto(produto_id)

    if produto is None:
        raise HTTPException(status_code=404, detail="Produto não encontrado.")

    return produto


@app.post("/produtos", response_model=Produto, status_code=201, tags=["Produtos"])
def criar_produto(dados: ProdutoEntrada):
    try:
        novo_id = executar(
            """
            INSERT INTO produto (Prod_Nome, Prod_Tipo, Prod_preco, Prod_qnt, Forn_ID_fk)
            VALUES (%s, %s, %s, %s, %s)
            """,
            (dados.nome, dados.tipo, dados.preco, dados.quantidade, dados.fornecedor_cnpj),
        )
    except mysql.connector.Error as e:
        erro_fornecedor(e)

    return buscar_produto(novo_id)


@app.put("/produtos/{produto_id}", response_model=Produto, tags=["Produtos"])
def atualizar_produto(produto_id: int, dados: ProdutoEntrada):
    if buscar_produto(produto_id) is None:
        raise HTTPException(status_code=404, detail="Produto não encontrado.")

    try:
        executar(
            """
            UPDATE produto
            SET Prod_Nome = %s, Prod_Tipo = %s, Prod_preco = %s,
                Prod_qnt = %s, Forn_ID_fk = %s
            WHERE Prod_ID = %s
            """,
            (dados.nome, dados.tipo, dados.preco, dados.quantidade,
             dados.fornecedor_cnpj, produto_id),
        )
    except mysql.connector.Error as e:
        erro_fornecedor(e)

    return buscar_produto(produto_id)


@app.delete("/produtos/{produto_id}", status_code=204, tags=["Produtos"])
def excluir_produto(produto_id: int):
    if buscar_produto(produto_id) is None:
        raise HTTPException(status_code=404, detail="Produto não encontrado.")

    try:
        executar("DELETE FROM produto WHERE Prod_ID = %s", (produto_id,))
    except mysql.connector.Error as e:
        if e.errno == errorcode.ER_ROW_IS_REFERENCED_2:
            raise HTTPException(
                status_code=409,
                detail="Produto já aparece em vendas e não pode ser excluído.",
            )
        raise


def erro_fornecedor(e):
    if e.errno == errorcode.ER_NO_REFERENCED_ROW_2:
        raise HTTPException(
            status_code=400,
            detail="Fornecedor não encontrado. Use um CNPJ cadastrado na tabela fornecedor.",
        )
    raise e


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", reload=True)
