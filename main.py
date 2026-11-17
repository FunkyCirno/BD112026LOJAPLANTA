import os
from contextlib import contextmanager
import mysql.connector
from mysql.connector import errorcode
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel, Field
load_dotenv()
app = FastAPI(
    title="Loja de Plantas",
    description='CRUD da tabela "produto", fast api mysql',
)
def conectar():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST", "localhost"),
        port=int(os.getenv("DB_PORT", "3306")),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD", ""),
        database=os.getenv("DB_NAME", "loja_de_plantas"),
    )
@contextmanager
def banco():
    con = conectar()
    cur = con.cursor(dictionary=True)
    try:
        yield con, cur
    finally:
        cur.close()
        con.close()
SELECT_PRODUTO = """
    SELECT Prod_ID    AS id,
           Prod_Nome  AS nome,
           Prod_Tipo  AS tipo,
           Prod_preco AS preco,
           Prod_qnt   AS quantidade,
           Forn_ID_fk AS fornecedor_cnpj
    FROM produto
"""
class ProdutoEntrada(BaseModel):
    nome: str = Field(min_length=1, examples=["Samambaia"])
    tipo: str = Field(min_length=1, examples=["Planta"])
    preco: float = Field(gt=0, le=99999.99, examples=[45.0])
    quantidade: int = Field(ge=0, examples=[10])
    fornecedor_cnpj: str = Field(min_length=14, max_length=14, examples=["12345678000199"])
class Produto(ProdutoEntrada):
    id: int
def buscar_produto(cur, produto_id: int):
    cur.execute(SELECT_PRODUTO + " WHERE Prod_ID = %s", (produto_id,))
    return cur.fetchone()
def erro_fornecedor(e: mysql.connector.Error):
    if e.errno == errorcode.ER_NO_REFERENCED_ROW_2:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Fornecedor não encontrado. Use um CNPJ cadastrado na tabela fornecedor.",
        )
    raise e
@app.get("/produtos", response_model=list[Produto], tags=["Produtos"])
def listar_produtos():
    with banco() as (con, cur):
        cur.execute(SELECT_PRODUTO + " ORDER BY Prod_ID")
        return cur.fetchall()
@app.get("/produtos/{produto_id}", response_model=Produto, tags=["Produtos"])
def obter_produto(produto_id: int):
    with banco() as (con, cur):
        produto = buscar_produto(cur, produto_id)
        if produto is None:
            raise HTTPException(status_code=404, detail="Produto não encontrado.")
        return produto
@app.post(
    "/produtos",
    response_model=Produto,
    status_code=status.HTTP_201_CREATED,
    tags=["Produtos"],
)
def criar_produto(dados: ProdutoEntrada):
    with banco() as (con, cur):
        try:
            cur.execute(
                """
                INSERT INTO produto (Prod_Nome, Prod_Tipo, Prod_preco, Prod_qnt, Forn_ID_fk)
                VALUES (%s, %s, %s, %s, %s)
                """,
                (dados.nome, dados.tipo, dados.preco, dados.quantidade, dados.fornecedor_cnpj),
            )
            con.commit()
        except mysql.connector.Error as e:
            con.rollback()
            erro_fornecedor(e)

        return buscar_produto(cur, cur.lastrowid)
@app.put("/produtos/{produto_id}", response_model=Produto, tags=["Produtos"])
def atualizar_produto(produto_id: int, dados: ProdutoEntrada):
    with banco() as (con, cur):
        if buscar_produto(cur, produto_id) is None:
            raise HTTPException(status_code=404, detail="Produto não encontrado.")

        try:
            cur.execute(
                """
                UPDATE produto
                SET Prod_Nome = %s, Prod_Tipo = %s, Prod_preco = %s,
                    Prod_qnt = %s, Forn_ID_fk = %s
                WHERE Prod_ID = %s
                """,
                (dados.nome, dados.tipo, dados.preco, dados.quantidade,
                 dados.fornecedor_cnpj, produto_id),
            )
            con.commit()
        except mysql.connector.Error as e:
            con.rollback()
            erro_fornecedor(e)

        return buscar_produto(cur, produto_id)
@app.delete(
    "/produtos/{produto_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    tags=["Produtos"],
)
def excluir_produto(produto_id: int):
    with banco() as (con, cur):
        if buscar_produto(cur, produto_id) is None:
            raise HTTPException(status_code=404, detail="Produto não encontrado.")

        try:
            cur.execute("DELETE FROM produto WHERE Prod_ID = %s", (produto_id,))
            con.commit()
        except mysql.connector.Error as e:
            con.rollback()
            if e.errno == errorcode.ER_ROW_IS_REFERENCED_2:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="Produto já aparece em vendas e não pode ser excluído.",
                )
            raise
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", reload=True)