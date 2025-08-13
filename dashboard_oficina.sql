-- criar banco de dados
-- create database oficina;
use oficina;

-- criar tabela cliente
create table clients (
    idClient int auto_increment primary key,
    Fname varchar(10),
    Lname varchar(10),
    Minit char(3),
    CPF char(11) not null,
    Address varchar(30),
    constraint unique_cpf_client unique(CPF)
);

-- criar tabela automóvel
create table automobile (
    idAutomobile int auto_increment primary key,
    idClient int,
    carType varchar(15),
    carModel varchar(20),
    licensePlate varchar(7) not null,
    abastecimento varchar(15),
    color varchar(30),
    renavan char(11),
    chassi varchar(17),
    previousOccurrences varchar(100) default null,
    complaint varchar(60) default null,
    constraint fk_automobile_client foreign key (idClient) references clients(idClient),
    constraint unique_licensePlate_automobile unique(licensePlate),
    constraint unique_renavan_automobile unique(renavan),
    constraint unique_chassi_automobile unique(chassi)
);

-- criar tabela mecânico
create table mecanic (
    idMecanic int auto_increment primary key,
    FName varchar(10),
    LName varchar(10),
    MCode int,
    Speciality varchar(15)
);

-- criar tabela equipe
create table team (
    idTeam int auto_increment primary key,
    teamName varchar(30)
);

-- relacionamento entre mecânico e equipe
create table mecanic_team (
    idMecanic int,
    idTeam int,
    primary key (idMecanic, idTeam),
    foreign key (idMecanic) references mecanic(idMecanic),
    foreign key (idTeam) references team(idTeam)
);

-- criar tabela Ordem de Serviço
create table serviceOrder (
    idServiceOrder int auto_increment primary key,
    idAutomobile int,
    idTeam int,
    Emission datetime,
    Deadline datetime,
    Avaliation varchar(60),
    SONumber int,
    constraint unique_SONumber_automobile unique(SONumber),
    constraint fk_serviceOrder_automobile foreign key (idAutomobile) references automobile(idAutomobile),
    constraint fk_serviceOrder_team foreign key (idTeam) references team(idTeam)
);

-- criar tabela precificação
create table precification (
    idPrecification int auto_increment primary key,
    idServiceOrder int,
    DefectivePart int default null,
    DescDefectivePart varchar(60) default null,
    totalValue float,
    constraint fk_precification_ServiceOrder foreign key (idServiceOrder) references serviceOrder(idServiceOrder)
);

-- criar tabela pagamento
create table payment (
    idPayment int auto_increment primary key,
    idClient int,
    idPrecification int,
    paymentDate date,
    typePayment enum('Boleto','Cartão','Dois cartões'),
    limitAvaliable float,
    constraint fk_payment_client foreign key(idClient) references clients(idClient),
    constraint fk_payment_precification foreign key(idPrecification) references precification(idPrecification)
);

-- Clientes
INSERT INTO clients (Fname, Lname, Minit, CPF, Address) VALUES
('João', 'Silva', 'A', '12345678901', 'Rua A, 100'),
('Maria', 'Souza', 'B', '98765432100', 'Av. B, 200'),
('Pedro', 'Oliveira', 'C', '45612378900', 'Rua C, 300');

-- Automóveis
INSERT INTO automobile (idClient, carType, carModel, licensePlate, abastecimento, color, renavan, chassi, previousOccurrences, complaint) VALUES
(1, 'Sedan', 'Civic', 'ABC1234', 'Gasolina', 'Preto', '11122233344', 'CHASSI00000000001', 'Troca de óleo', 'frear em baixa'),
(2, 'SUV', 'Compass', 'XYZ5678', 'Diesel', 'Branco', '22233344455', 'CHASSI00000000002', NULL, 'barulho ao ligar'),
(3, 'Hatch', 'Gol', 'DEF8901', 'Flex', 'Vermelho', '33344455566', 'CHASSI00000000003', 'Pneu furado', NULL);

-- Mecânicos
INSERT INTO mecanic (FName, LName, MCode, Speciality) VALUES
('Carlos', 'Pereira', 101, 'Motor'),
('Ana', 'Lima', 102, 'Suspensão'),
('Rafael', 'Mendes', 103, 'Freios');

-- Equipes
INSERT INTO team (teamName) VALUES
('Equipe A'),
('Equipe B');

-- Relação mecânico ↔ equipe
INSERT INTO mecanic_team (idMecanic, idTeam) VALUES
(1, 1),
(2, 1),
(3, 2);

-- Ordens de Serviço
INSERT INTO serviceOrder (idAutomobile, idTeam, Emission, Deadline, Avaliation, SONumber) VALUES
(1, 1, '2025-08-01 08:00:00', '2025-08-05 18:00:00', 'Boa', 1001),
(2, 1, '2025-08-02 09:00:00', '2025-08-06 17:00:00', 'Regular', 1002),
(3, 2, '2025-08-03 10:00:00', '2025-08-07 16:00:00', 'Ótima', 1003);

-- Precificação
INSERT INTO precification (idServiceOrder, DefectivePart, DescDefectivePart, totalValue) VALUES
(1, 2, 'Pastilhas de freio', 900),
(2, 1, 'Correia dentada', 500),
(3, NULL, NULL, 1600);

-- Pagamentos
INSERT INTO payment (idClient, idPrecification, paymentDate, typePayment, limitAvaliable) VALUES
(1, 1, '2025-08-06', 'Cartão', 2000),
(2, 2, '2025-08-07', 'Boleto', 1500),
(3, 3, '2025-08-08', 'Dois cartões', 3000);

-- Recuperação simples
SELECT carModel, carType FROM automobile;

-- Filtro com WHERE
SELECT * FROM automobile
WHERE complaint LIKE '%frear%';

-- Atributo derivado
SELECT 
    CONCAT(Fname, ' ', Minit, '. ', Lname) AS NomeCompleto,
    LENGTH(CONCAT(Fname, ' ', Minit, '. ', Lname)) AS TamanhoNome
FROM clients;

-- ORDER BY
SELECT carModel, color FROM automobile
ORDER BY color ASC;

-- Pagamentos ordenados por valor disponível (decrescente)
SELECT * FROM payment
ORDER BY limitAvaliable DESC;

-- HAVING (valor por equipe > 1500)
SELECT 
    idTeam,
    SUM(totalValue) AS totalEquipe
FROM serviceOrder
JOIN precification ON serviceOrder.idServiceOrder = precification.idServiceOrder
GROUP BY idTeam
HAVING SUM(totalValue) > 1500;

-- JOIN cliente ↔ automóvel
SELECT 
    c.Fname AS Cliente,
    a.carModel AS Modelo,
    a.licensePlate AS Placa
FROM clients c
JOIN automobile a ON c.idClient = a.idClient;

-- JOIN mecânico ↔ equipe
SELECT 
    m.FName AS Mecanico,
    m.Speciality,
    t.teamName
FROM mecanic m
JOIN mecanic_team mt ON m.idMecanic = mt.idMecanic
JOIN team t ON mt.idTeam = t.idTeam;

-- Listar clientes, modelo do carro e valor total da OS apenas para ordens com valor > 800, ordenando por valor desc
SELECT DISTINCT
    c.Fname AS Cliente,
    a.carModel AS Modelo,
    p.totalValue AS ValorOS
FROM clients c
JOIN automobile a ON c.idClient = a.idClient
JOIN serviceOrder so ON a.idAutomobile = so.idAutomobile
JOIN precification p ON so.idServiceOrder = p.idServiceOrder
WHERE p.totalValue > 800
ORDER BY p.totalValue DESC;

-- Mostrar todas as ordens, com nome da equipe, mecânicos envolvidos e prazo em dias para conclusão
SELECT 
    so.SONumber,
    t.teamName,
    GROUP_CONCAT(CONCAT(m.FName, ' ', m.LName) SEPARATOR ', ') AS Mecanicos,
    DATEDIFF(so.Deadline, so.Emission) AS PrazoDias
FROM serviceOrder so
JOIN team t ON so.idTeam = t.idTeam
JOIN mecanic_team mt ON t.idTeam = mt.idTeam
JOIN mecanic m ON mt.idMecanic = m.idMecanic
GROUP BY so.SONumber, t.teamName, so.Emission, so.Deadline;