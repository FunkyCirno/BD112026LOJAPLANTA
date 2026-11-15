-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 14/11/2026 às 02:49
-- Versão do servidor: 8.0.46
-- Versão do PHP: 8.3.36

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `loja_de_plantas`
--
CREATE DATABASE IF NOT EXISTS `loja_de_plantas` DEFAULT CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci;
USE `loja_de_plantas`;

-- --------------------------------------------------------

--
-- Estrutura para tabela `cliente`
--

CREATE TABLE `cliente` (
  `Cliente_ID` varchar(11) NOT NULL,
  `Nome` text NOT NULL,
  `Endereco` text NOT NULL
) ;

--
-- Despejando dados para a tabela `cliente`
--

INSERT INTO `cliente` (`Cliente_ID`, `Nome`, `Endereco`) VALUES
('12345678911', 'Paulo', 'Fortaleza'),
('12345678912', 'Eduardo', 'Fortaleza'),
('12345678913', 'Diego', 'Freitas'),
('12345678914', 'Pedro', 'Fortazela'),
('12345678915', 'Hugo', 'Russas'),
('12345678916', 'Raul', 'Alto Santo'),
('12345678917', 'Luanderson', 'Piaui'),
('12345678918', 'Paulo Henrique', 'Tabuleiro do Norte'),
('13245678910', 'Samuel', 'Mulungu do Morro');

-- --------------------------------------------------------

--
-- Estrutura para tabela `fornecedor`
--

CREATE TABLE `fornecedor` (
  `Forn_CNPJ` varchar(14) NOT NULL,
  `Forn_Nome` text NOT NULL,
  `Forn_Endereco` text NOT NULL
) ;

--
-- Despejando dados para a tabela `fornecedor`
--

INSERT INTO `fornecedor` (`Forn_CNPJ`, `Forn_Nome`, `Forn_Endereco`) VALUES
('11222333000144', 'Plantando o Bem', 'Travessa São José, 25 - Catumbela'),
('12345678000199', 'Distribuidora Sol Nascente', 'Rua Padre Zacarias, 410 - Planalto'),
('33444555000166', 'Lita Flores', 'Rua Dr. José Ramalho, 340 - Centro'),
('45678912000133', 'Primavera', 'Rua Benjamim Constant, 88 - Ipiranga'),
('55666777000188', 'Fertil', 'Rua Monsenhor João Luiz, 612 - Centro'),
('87654334569012', 'Portal do Verde', 'Av. Dom Lino, 153 - Centro'),
('98765432000155', 'Atacadão Das Plantas', 'Av. Cel. Araújo Lima, 1020 - Centro'),
('99888777000122', 'Verde Vital', 'Rodovia BR-116, Km 160 - Zona Rural');

-- --------------------------------------------------------

--
-- Estrutura para tabela `funcionario`
--

CREATE TABLE `funcionario` (
  `Func_ID` varchar(11) NOT NULL,
  `Nome` text NOT NULL,
  `Salario` double(7,2) NOT NULL
) ;

--
-- Despejando dados para a tabela `funcionario`
--

INSERT INTO `funcionario` (`Func_ID`, `Nome`, `Salario`) VALUES
('10145501098', 'Brolyy', 228.12),
('23152738191', 'MAK', 2342.12),
('46186532198', 'Yuz', 3312.12),
('60520321281', 'Wess', 4000.12),
('83182232394', 'Lopes', 11000.12),
('93182023198', 'Lores', 2012.12),
('93182032198', 'Kyna', 1922.12);

-- --------------------------------------------------------

--
-- Estrutura para tabela `produto`
--

CREATE TABLE `produto` (
  `Prod_ID` int NOT NULL,
  `Forn_ID_fk` varchar(14) NOT NULL,
  `Prod_Tipo` text NOT NULL,
  `Prod_preco` double(7,2) NOT NULL,
  `Prod_Nome` text NOT NULL,
  `Prod_qnt` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Despejando dados para a tabela `produto`
--

INSERT INTO `produto` (`Prod_ID`, `Forn_ID_fk`, `Prod_Tipo`, `Prod_preco`, `Prod_Nome`, `Prod_qnt`) VALUES
(4, '11222333000144', 'Planta', 50.00, 'Costela de Adao', 5),
(5, '55666777000188', 'Planta', 5000.00, 'Flor Monstro', 2),
(6, '33444555000166', 'Planta', 67.00, 'Chifre Superbum', 5),
(7, '45678912000133', 'Planta', 50.00, 'Singônio Rosa', 1),
(8, '12345678000199', 'Fertilizante', 10.00, 'Forth Jardim', 20),
(9, '12345678000199', 'Fertilizante', 30.00, 'Fertilizante NPK Concentrado', 44),
(10, '12345678000199', 'Fertilizante', 50.00, 'Casca Verde', 79),
(11, '87654334569012', 'Planta', 431.00, 'Magnolia', 19),
(12, '87654334569012', 'Vaso', 1111.00, 'Vaso Egipcio', 21),
(13, '87654334569012', 'Vaso', 35.00, 'Vaso Comum', 10),
(14, '98765432000155', 'Vaso', 30.00, 'Vaso Comum', 12),
(15, '99888777000122', 'Planta', 31.00, 'Filodendro', 32);

-- --------------------------------------------------------

--
-- Estrutura para tabela `produtovenda`
--

CREATE TABLE `produtovenda` (
  `Prod_ID_fk` int NOT NULL,
  `Venda_Venda_ID` int NOT NULL,
  `ItensV_qnt` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Despejando dados para a tabela `produtovenda`
--

INSERT INTO `produtovenda` (`Prod_ID_fk`, `Venda_Venda_ID`, `ItensV_qnt`) VALUES
(4, 16, 2),
(5, 16, 10),
(6, 16, 10);

-- --------------------------------------------------------

--
-- Estrutura para tabela `venda`
--

CREATE TABLE `venda` (
  `Venda_ID` int NOT NULL,
  `Venda_Data` datetime DEFAULT CURRENT_TIMESTAMP,
  `Cliente_ID` varchar(11) NOT NULL,
  `Func_ID` varchar(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Despejando dados para a tabela `venda`
--

INSERT INTO `venda` (`Venda_ID`, `Venda_Data`, `Cliente_ID`, `Func_ID`) VALUES
(16, '2026-11-13 15:34:37', '12345678911', '10145501098'),
(17, '2026-11-13 15:34:37', '12345678912', '23152738191'),
(18, '2026-11-13 15:34:37', '12345678913', '46186532198'),
(19, '2026-11-13 15:34:37', '12345678914', '83182232394'),
(20, '2026-11-13 15:34:37', '12345678915', '60520321281');

--
-- Índices para tabelas despejadas
--

--
-- Índices de tabela `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`Cliente_ID`);

--
-- Índices de tabela `fornecedor`
--
ALTER TABLE `fornecedor`
  ADD PRIMARY KEY (`Forn_CNPJ`);

--
-- Índices de tabela `funcionario`
--
ALTER TABLE `funcionario`
  ADD PRIMARY KEY (`Func_ID`);

--
-- Índices de tabela `produto`
--
ALTER TABLE `produto`
  ADD PRIMARY KEY (`Prod_ID`),
  ADD KEY `Forn_ID_fk_idx` (`Forn_ID_fk`);

--
-- Índices de tabela `produtovenda`
--
ALTER TABLE `produtovenda`
  ADD PRIMARY KEY (`Prod_ID_fk`,`Venda_Venda_ID`),
  ADD KEY `fk_Produto_has_Venda_Venda1_idx` (`Venda_Venda_ID`),
  ADD KEY `fk_Produto_has_Venda_Produto1_idx` (`Prod_ID_fk`);

--
-- Índices de tabela `venda`
--
ALTER TABLE `venda`
  ADD PRIMARY KEY (`Venda_ID`),
  ADD KEY `Cliente_ID_idx` (`Cliente_ID`),
  ADD KEY `Func_ID_idx` (`Func_ID`);

--
-- AUTO_INCREMENT para tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `produto`
--
ALTER TABLE `produto`
  MODIFY `Prod_ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT de tabela `venda`
--
ALTER TABLE `venda`
  MODIFY `Venda_ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- Restrições para tabelas despejadas
--

--
-- Restrições para tabelas `produto`
--
ALTER TABLE `produto`
  ADD CONSTRAINT `Forn_ID_fk` FOREIGN KEY (`Forn_ID_fk`) REFERENCES `fornecedor` (`Forn_CNPJ`) ON DELETE RESTRICT;

--
-- Restrições para tabelas `produtovenda`
--
ALTER TABLE `produtovenda`
  ADD CONSTRAINT `fk_Produto_has_Venda_Produto1` FOREIGN KEY (`Prod_ID_fk`) REFERENCES `produto` (`Prod_ID`),
  ADD CONSTRAINT `fk_Produto_has_Venda_Venda1` FOREIGN KEY (`Venda_Venda_ID`) REFERENCES `venda` (`Venda_ID`);

--
-- Restrições para tabelas `venda`
--
ALTER TABLE `venda`
  ADD CONSTRAINT `Cliente_ID` FOREIGN KEY (`Cliente_ID`) REFERENCES `cliente` (`Cliente_ID`) ON DELETE RESTRICT,
  ADD CONSTRAINT `Func_ID` FOREIGN KEY (`Func_ID`) REFERENCES `funcionario` (`Func_ID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
