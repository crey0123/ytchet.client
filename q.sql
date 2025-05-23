DROP DATABASE IF EXISTS saqt;

--  Создаем базу данных
CREATE DATABASE saqt CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--  Выбираем базу данных для использования
USE saqt;

-- Создание таблицы Positions (Должности)
CREATE TABLE Positions (
    PositionID INT PRIMARY KEY AUTO_INCREMENT,
    PositionName VARCHAR(255) NOT NULL,
    Description TEXT  -- Описание должности (опционально)
);

-- Заполнение данными для таблицы Positions
INSERT INTO Positions (PositionName, Description) VALUES
('Следователь', 'Сотрудник следственного комитета'),
('Старший следователь', 'Старший сотрудник следственного комитета'),
('Аналитик', 'Специалист по анализу данных'),
('Руководитель отдела', 'Руководитель подразделения');

-- Создание таблицы AccessBases (Базы доступа)
CREATE TABLE AccessBases (
    AccessBaseID INT PRIMARY KEY AUTO_INCREMENT,
    AccessBaseName VARCHAR(255) NOT NULL,
    RequiredFields JSON NULL  -- JSON-массив с описанием необходимых полей (может быть пустым)
    -- additional_fields TEXT NULL  -- Этот столбец больше не нужен. Используйте RequiredFields JSON
);



-- Создание таблицы Pairs (Пары)
CREATE TABLE Pairs (
    PairID INT PRIMARY KEY AUTO_INCREMENT,
    PairName VARCHAR(255) NOT NULL  -- Например, "Брест и Брестская область"
);

-- Создание таблицы Departments (Подразделения)
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY AUTO_INCREMENT,
    DepartmentName VARCHAR(255) NOT NULL,
    PairID INT,  -- Идентификатор "пары"
    FOREIGN KEY (PairID) REFERENCES Pairs(PairID)
);

-- Создание таблицы Clients (Общая информация о клиентах)
CREATE TABLE Clients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fio VARCHAR(255) NOT NULL,
    PositionID INT NULL,  -- Разрешаем NULL
    DepartmentID INT NULL,  -- Из VARCHAR в INT
    date_added TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (PositionID) REFERENCES Positions(PositionID),  -- Исправлено на PositionID
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID) -- Исправлено на DepartmentID
);

-- Таблица связи между пользователями и базами данных
CREATE TABLE Client_AccessBase (
    Client_id INT NOT NULL,
    AccessBaseID INT NOT NULL,
    PRIMARY KEY (Client_id, AccessBaseID),
    FOREIGN KEY (Client_id) REFERENCES Clients(id),
    FOREIGN KEY (AccessBaseID) REFERENCES AccessBases(AccessBaseID) -- Исправлено на AccessBaseID
);

--  Таблица с дополнительной информацией о пользователях
CREATE TABLE additional_info (
    id INT AUTO_INCREMENT PRIMARY KEY,
    Client_id INT NOT NULL,  --  Исправлено: Client_id вместо user_id, чтобы соответствовать FK
    birthdate DATE NULL,
    id_nomer VARCHAR(255) NULL,
    email VARCHAR(255) NULL,
    phone VARCHAR(20),
    profile VARCHAR(255) NULL,
    ecp_key VARCHAR(255) NULL,
    FOREIGN KEY (Client_id) REFERENCES Clients(id)  --  Исправлено на Clients(id)
);

CREATE TABLE Administrators (
    AdministratorID INT PRIMARY KEY AUTO_INCREMENT,
    Username VARCHAR(50) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL --  Убрали лишние поля для соответствия задаче
);

-- Создание таблицы UserPairs (Администратор - Пара)
CREATE TABLE UserPairs (
    AdministratorID INT,
    PairID INT,
    PRIMARY KEY (AdministratorID, PairID),
    FOREIGN KEY (AdministratorID) REFERENCES Administrators(AdministratorID),
    FOREIGN KEY (PairID) REFERENCES Pairs(PairID)
);


-- Создание таблицы отчетов
CREATE TABLE Reports (
    ReportID INT AUTO_INCREMENT PRIMARY KEY,      -- Уникальный идентификатор отчета
    ReportDate DATE NOT NULL,                     -- Дата формирования отчета
    RecordCount INT NOT NULL,                     -- Количество записей в отчете
    DepartmentID INT NULL,                        -- Связь с таблицей Departments
    AccessBaseID INT NULL,                        -- Связь с таблицей AccessBases
    ClientID INT NULL,                            -- Связь с таблицей Clients
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID),
    FOREIGN KEY (AccessBaseID) REFERENCES AccessBases(AccessBaseID),
    FOREIGN KEY (ClientID) REFERENCES Clients(id)
);

INSERT INTO Reports (ReportDate, RecordCount, DepartmentID, AccessBaseID, ClientID)
VALUES ('2025-03-19', 120, 
        (SELECT DepartmentID FROM Departments WHERE DepartmentName = 'УСК по Брестской области'), 
        (SELECT AccessBaseID FROM AccessBases WHERE AccessBaseName = 'АИС Гражданство и миграция'), 
        (SELECT id FROM Clients WHERE fio = 'Иван Иванов'));

-- Заполнение данными для таблицы AccessBases
INSERT INTO AccessBases (AccessBaseName, RequiredFields) VALUES
('АИС Гражданство и миграция', '[]'),
('ПС ЕГБДП', '[{"name": "profile", "type": "text", "label": "Профиль ПС ЕГБДП"}]'),  
('АС ЕГБДП', '[{"name": "birthdate", "type": "date", "label": "Дата рождения"}]'),
('ИС "Оперативные сведения"', '[]'),
('АИС ГАИ', '[{"name": "birthdate", "type": "date", "label": "Дата рождения"}, {"name": "id_nomer", "type": "text", "label": "ID-номер"}]'),
('АИС "Розыск АМТ"', '[]'),
('РСМОБ', '[{"name": "email", "type": "email", "label": "e-mail"}, {"name": "phone", "type": "tel", "label": "Номер телефона"}]'), 
('ilex', '[{"name": "email", "type": "email", "label": "e-mail"}, {"name": "phone", "type": "tel", "label": "Номер телефона"}]'), 
('ЭТАЛОН-ONLINE', '[{"name": "email", "type": "email", "label": "e-mail"}]'),
('АИС ЕГР', '[{"name": "ecp_key", "type": "text", "label": "Ключ ЭЦП"}]'), 
('ЕАИС СК', '[]'),
('АИС Конфискат', '[]');

-- Заполнение данными для таблицы Pairs
INSERT INTO Pairs (PairName) VALUES
('Центральный аппарат Минска'),
('Город Минск'),
('Брест и Брестская область'),
('Витебск и Витебская область'),
('Гомель и Гомельская область'),
('Гродно и Гродненская область'),
('Минская область'),
('Могилев и Могилевская область');


-- Заполнение данными для таблицы Departments
INSERT INTO Departments (DepartmentName, PairID) VALUES
('Центральный аппарат', (SELECT PairID FROM Pairs WHERE PairName = 'Центральный аппарат Минска')),
('Институт Следственного комитета', (SELECT PairID FROM Pairs WHERE PairName = 'Центральный аппарат Минска')),

('УСК по г. Минску', (SELECT PairID FROM Pairs WHERE PairName = 'Город Минск')),
('Заводской (г. Минска) РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Город Минск')),
('Ленинский (г. Минска) РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Город Минск')),
('Московский (г. Минска) РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Город Минск')),
('Октябрьский (г. Минска) РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Город Минск')),
('Партизанский (г. Минска) РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Город Минск')),
('Первомайский (г. Минска) РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Город Минск')),
('Советский (г. Минска) РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Город Минск')),
('Фрунзенский (г. Минска) РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Город Минск')),
('Центральный (г. Минска) РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Город Минск')),

('УСК по Брестской области', (SELECT PairID FROM Pairs WHERE PairName = 'Брест и Брестская область')),
('Барановичский МОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Брест и Брестская область')),
('Березовский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Брест и Брестская область')),
('Брестский МОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Брест и Брестская область')),
('Ганцевичский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Брест и Брестская область')),
('Дрогичинский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Брест и Брестская область')),
('Жабинковский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Брест и Брестская область')),
('Ивановский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Брест и Брестская область')),
('Ивацевичский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Брест и Брестская область')),
('Каменецкий РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Брест и Брестская область')),
('Кобринский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Брест и Брестская область')),
('Лунинецкий РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Брест и Брестская область')),
('Ляховичский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Брест и Брестская область')),
('Малоритский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Брест и Брестская область')),
('Пинский МОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Брест и Брестская область')),
('Пружанский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Брест и Брестская область')),
('Столинский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Брест и Брестская область')),

('УСК по Витебской области', (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),
('Бешенковичский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),
('Браславский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),
('Верхнедвинский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),
('Витебский ГОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),
('Витебский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),
('Глубокский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),
('Городокский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),
('Докшицкий РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),
('Дубровенский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),
('Лепельский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),
('Лиозненский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),
('Миорский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),
('Новополоцкий ГОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),
('Оршанский МОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),
('Полоцкий МОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),
('Поставский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),
('Россонский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),
('Сенненский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),
('Толочинский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),
('Ушачский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),
('Чашникский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),
('Шарковщинский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),
('Шумилинский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),

('УСК по Гомельской области', (SELECT PairID FROM Pairs WHERE PairName = 'Гомель и Гомельская область')),
('Брагинский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гомель и Гомельская область')),
('Буда-Кошелевский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гомель и Гомельская область')),
('Ветковский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гомель и Гомельская область')),
('Гомельский ГОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гомель и Гомельская область')),
('Гомельский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гомель и Гомельская область')),
('Добрушский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гомель и Гомельская область')),
('Ельский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гомель и Гомельская область')),
('Житковичский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гомель и Гомельская область')),
('Жлобинский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гомель и Гомельская область')),
('Калинковичский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гомель и Гомельская область')),
('Кормянский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гомель и Гомельская область')),
('Лельчицкий РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гомель и Гомельская область')),
('Лоевский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гомель и Гомельская область')),
('Мозырский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гомель и Гомельская область')),
('Наровлянский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гомель и Гомельская область')),
('Октябрьский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гомель и Гомельская область')),
('Петриковский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гомель и Гомельская область')),
('Речицкий РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гомель и Гомельская область')),
('Рогачевский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гомель и Гомельская область')),
('Светлогорский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гомель и Гомельская область')),
('Хойникский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гомель и Гомельская область')),
('Чечерский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гомель и Гомельская область')),

('УСК по Гродненской области', (SELECT PairID FROM Pairs WHERE PairName = 'Гродно и Гродненская область')),
('Берестовицкий РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гродно и Гродненская область')),
('Волковысcкий РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гродно и Гродненская область')),
('Вороновский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гродно и Гродненская область')),
('Гродненский МОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гродно и Гродненская область')),
('Дятловский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гродно и Гродненская область')),
('Зельвенский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гродно и Гродненская область')),
('Ивьевский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гродно и Гродненская область')),
('Кореличский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гродно и Гродненская область')),
('Лидский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гродно и Гродненская область')),
('Мостовский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гродно и Гродненская область')),
('Новогрудский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гродно и Гродненская область')),
('Островецкий РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гродно и Гродненская область')),
('Ошмянский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гродно и Гродненская область')),
('Свислочский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гродно и Гродненская область')),
('Слонимский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гродно и Гродненская область')),
('Сморгонский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гродно и Гродненская область')),
('Щучинский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Гродно и Гродненская область')),

('УСК по Минской области', (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),
('Березинский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),
('Борисовский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),
('Вилейский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),
('Воложинский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),
('Жодинский ГОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),
('Дзержинский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),
('Клецкий РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),
('Копыльский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),
('Крупский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),
('Логойский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),
('Любанский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),
('Минский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),
('Молодечненский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),
('Мядельский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),
('Несвижский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),
('Пуховичский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),
('Слуцкий РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),
('Смолевичский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),
('Солигорский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),
('Стародорожский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),
('Столбцовский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),
('Узденский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),
('Червенский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),

('УСК по Могилевской области', (SELECT PairID FROM Pairs WHERE PairName = 'Могилев и Могилевская область')),
('Белыничский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Могилев и Могилевская область')),
('Бобруйский МОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Могилев и Могилевская область')),
('Быховский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Могилев и Могилевская область')),
('Глусский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Могилев и Могилевская область')),
('Горецкий РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Могилев и Могилевская область')),
('Дрибинский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Могилев и Могилевская область')),
('Кировский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Могилев и Могилевская область')),
('Климовичский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Могилев и Могилевская область')),
('Кличевский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Могилев и Могилевская область')),
('Костюковичский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Могилев и Могилевская область')),
('Краснопольский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Могилев и Могилевская область')),
('Кричевский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Могилев и Могилевская область')),
('Круглянский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Могилев и Могилевская область')),
('Могилевский МОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Могилев и Могилевская область')),
('Мстиславский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Могилев и Могилевская область')),
('Осиповичский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Могилев и Могилевская область')),
('Славгородский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Могилев и Могилевская область')),
('Хотимский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Могилев и Могилевская область')),
('Чаусский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Могилев и Могилевская область')),
('Чериковский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Могилев и Могилевская область')),
('Шкловский РОСК', (SELECT PairID FROM Pairs WHERE PairName = 'Могилев и Могилевская область'));

-- Заполнение данными для таблицы Administrators (ВАЖНО: используйте хэширование паролей!)
INSERT INTO Administrators (Username, Password) VALUES
('minsk_admin', '$2b$12$d9XGipZOcOX43Dr6OQ65JutNXicHf2e4ZMXeWcDfECaiAEU7Ksdni'),
('brest_admin', '$2b$12$KFjW0/HR6Bb2CcqD6t7v8e53lrKdIUYbEZhaqXYoiq6gCxAKXCN1m'),
('vitebsk_admin', '$2b$12$H2Rf1P2rsQVKkKZddORzE.XzgYxeIRxiLeIJEoK4RMzG3p0iNf0Zu'),
('gomel_admin', '$2b$12$qGzVBIDAVNIiV..LG8W4jugINeHeEVq0sJnYSIuADSdBuMgZC3BHS'),
('grodno_admin', '$2b$12$qIxNf3vuLXF6c6S0dEZiEutMM0S7Y7p7LIrxvtCi9lWDm4951ZxLi'),
('minsk_obl_admin', '$2b$12$Fol6/EhqG2cbxOe6.IRATul5um/tXpUt3sJudgvp5pwcQm.z2q6UK'),
('mogilev_admin', '$2b$12$MM5gPOCOdr5r75C99MpXYeo8Qsjy96VPg26PhBl1CJrCCwe2.HetG'),
('sity_minsk', '$2b$12$sNFyAMUCQIChItTwoOITneUChNMgJcXH8/yXJmDer94guxTobv6fu'),
('minsk_admin1', '$2b$12$mOAWyzQlcMadLxIfioHVje15zvaoczNgFqwt9rO8PhboHBkIqFXGm'),
('brest_admin1', '$2b$12$KFjW0/HR6Bb2CcqD6t7v8e53lrKdIUYbEZhaqXYoiq6gCxAKXCN1m'),
('vitebsk_admin1', '$2b$12$H2Rf1P2rsQVKkKZddORzE.XzgYxeIRxiLeIJEoK4RMzG3p0iNf0Zu'),
('gomel_admin1', '$2b$12$qGzVBIDAVNIiV..LG8W4jugINeHeEVq0sJnYSIuADSdBuMgZC3BHS'),
('grodno_admin1', '$2b$12$qIxNf3vuLXF6c6S0dEZiEutMM0S7Y7p7LIrxvtCi9lWDm4951ZxLi'),
('minsk_obl_admin1', '$2b$12$Fol6/EhqG2cbxOe6.IRATul5um/tXpUt3sJudgvp5pwcQm.z2q6UK'),
('mogilev_admin1', '$2b$12$MM5gPOCOdr5r75C99MpXYeo8Qsjy96VPg26PhBl1CJrCCwe2.HetG'),
('sity_minsk1', '$2b$12$sNFyAMUCQIChItTwoOITneUChNMgJcXH8/yXJmDer94guxTobv6fu');

-- Связывание администраторов с их соответствующими парами
INSERT INTO UserPairs (AdministratorID, PairID) VALUES
((SELECT AdministratorID FROM Administrators WHERE Username = 'minsk_admin'), (SELECT PairID FROM Pairs WHERE PairName = 'Центральный аппарат Минска')),
((SELECT AdministratorID FROM Administrators WHERE Username = 'sity_minsk'), (SELECT PairID FROM Pairs WHERE PairName = 'Город Минск')),
((SELECT AdministratorID FROM Administrators WHERE Username = 'brest_admin'), (SELECT PairID FROM Pairs WHERE PairName = 'Брест и Брестская область')),
((SELECT AdministratorID FROM Administrators WHERE Username = 'vitebsk_admin'), (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),
((SELECT AdministratorID FROM Administrators WHERE Username = 'gomel_admin'), (SELECT PairID FROM Pairs WHERE PairName = 'Гомель и Гомельская область')),
((SELECT AdministratorID FROM Administrators WHERE Username = 'grodno_admin'), (SELECT PairID FROM Pairs WHERE PairName = 'Гродно и Гродненская область')),
((SELECT AdministratorID FROM Administrators WHERE Username = 'minsk_obl_admin'), (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),
((SELECT AdministratorID FROM Administrators WHERE Username = 'mogilev_admin'), (SELECT PairID FROM Pairs WHERE PairName = 'Могилев и Могилевская область')),
((SELECT AdministratorID FROM Administrators WHERE Username = 'minsk_admin1'), (SELECT PairID FROM Pairs WHERE PairName = 'Центральный аппарат Минска')),
((SELECT AdministratorID FROM Administrators WHERE Username = 'sity_minsk1'), (SELECT PairID FROM Pairs WHERE PairName = 'Город Минск')),
((SELECT AdministratorID FROM Administrators WHERE Username = 'brest_admin1'), (SELECT PairID FROM Pairs WHERE PairName = 'Брест и Брестская область')),
((SELECT AdministratorID FROM Administrators WHERE Username = 'vitebsk_admin1'), (SELECT PairID FROM Pairs WHERE PairName = 'Витебск и Витебская область')),
((SELECT AdministratorID FROM Administrators WHERE Username = 'gomel_admin1'), (SELECT PairID FROM Pairs WHERE PairName = 'Гомель и Гомельская область')),
((SELECT AdministratorID FROM Administrators WHERE Username = 'grodno_admin1'), (SELECT PairID FROM Pairs WHERE PairName = 'Гродно и Гродненская область')),
((SELECT AdministratorID FROM Administrators WHERE Username = 'minsk_obl_admin1'), (SELECT PairID FROM Pairs WHERE PairName = 'Минская область')),
((SELECT AdministratorID FROM Administrators WHERE Username = 'mogilev_admin1'), (SELECT PairID FROM Pairs WHERE PairName = 'Могилев и Могилевская область'));




 -- 1. Проверка существования пользователей
SELECT * FROM Administrators WHERE Username IN ('minsk_admin', 'brest_admin', 'vitebsk_admin' );

-- 2. Проверка хешей (извлечение и отображение хешей)
SELECT Username, Password FROM Administrators WHERE Username IN ('minsk_admin', 'brest_admin');


USE saqt;
SELECT * FROM additional_info;

SELECT * FROM additional_info WHERE Client_id IN (SELECT id FROM Clients);


SELECT c.fio, p.PositionName, d.DepartmentName, a.AccessBaseName,
       c.date_added, c.deleted_at,
       ai.birthdate, ai.id_nomer, ai.email, ai.phone, ai.profile, ai.ecp_key
FROM Clients c
LEFT JOIN Positions p ON c.PositionID = p.PositionID
LEFT JOIN Departments d ON c.DepartmentID = d.DepartmentID
LEFT JOIN Client_AccessBase cab ON c.id = cab.Client_id
LEFT JOIN AccessBases a ON cab.AccessBaseID = a.AccessBaseID
LEFT JOIN additional_info ai ON c.id = ai.Client_id;


