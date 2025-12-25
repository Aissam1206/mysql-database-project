DROP DATABASE IF EXISTS smartlib;
CREATE DATABASE smartlib;
USE smartlib;

-- ============================
-- TABLES
-- ============================

CREATE TABLE Member (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    membership_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(12) NOT NULL DEFAULT 'active',
    CONSTRAINT chk_member_status CHECK (status IN ('active','inactive','suspended'))
);

CREATE TABLE Librarian (
    librarian_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    hire_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(12) NOT NULL DEFAULT 'active',
    CONSTRAINT chk_librarian_status CHECK (status IN ('active','inactive'))
);

CREATE TABLE Book (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    publisher VARCHAR(200),
    published_year INT CHECK (published_year > 0),
    librarian_id INT,
    FOREIGN KEY (librarian_id) REFERENCES Librarian(librarian_id)
);

CREATE TABLE Borrow (
    borrow_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    book_id INT NOT NULL,
    librarian_id INT,
    issue_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    due_date DATETIME,
    return_date DATETIME,
    status VARCHAR(12) NOT NULL DEFAULT 'Borrowed',
    FOREIGN KEY (member_id) REFERENCES Member(member_id),
    FOREIGN KEY (book_id) REFERENCES Book(book_id),
    FOREIGN KEY (librarian_id) REFERENCES Librarian(librarian_id),
    CONSTRAINT chk_borrow_status CHECK (status IN ('Borrowed', 'Returned', 'Overdue'))
);

ALTER TABLE Borrow
ADD CONSTRAINT due_after_issue CHECK (due_date >= issue_date),
ADD CONSTRAINT return_after_issue CHECK (return_date IS NULL OR return_date >= issue_date);

-- ============================
-- INSERT MEMBERS
-- ============================

INSERT INTO Member (name, email, status) VALUES
('Hiba Bouriale', 'hiba@gmail.com', 'active'),
('Ahmed Khair', 'ahmed@gmail.com', 'active'),
('Ali Karim', 'ali@gmail.com', 'active'),
('Kenza Bennani', 'kenza@gmail.com', 'suspended'),
('Omar Rahmani', 'omar@gmail.com', 'inactive'),
('Amina Zahra', 'amina@gmail.com', 'active');

-- ============================
-- INSERT LIBRARIANS
-- ============================

INSERT INTO Librarian (name, email, status) VALUES
('John Wilson', 'wilson@gmail.com', 'active'),
('Sara Johnson', 'johnson@gmail.com', 'active'),
('Youssef Amrani', 'amrani@gmail.com', 'active'),
('Maha Idrissi', 'idrissi@gmail.com', 'inactive'),
('Adam Pearson', 'pearson@gmail.com', 'active');

-- ============================
-- INSERT BOOKS
-- ============================

INSERT INTO Book (title, isbn, publisher, published_year, librarian_id) VALUES
('Data Science Basics', '111', 'TechPress', 2020, 1),
('Advanced SQL and Data', '222', 'ITBooks', 2019, 2),
('Artificial Intelligence', '333', 'FutureTech', 2021, 3),
('Psychology of Success', '444', 'MindPub', 2018, 4),
('Romantic Stories', '555', 'LoveBooks', 2015, 5),
('Never Borrowed Book', '666', 'UnusedPress', 2022, 1);

-- ============================
-- INSERT BORROWS (10 ROWS)
-- ============================

INSERT INTO Borrow (member_id, book_id, librarian_id, issue_date, due_date, return_date, status) VALUES
(1, 1, 1, NOW() - INTERVAL 10 DAY, NOW() - INTERVAL 3 DAY, NULL, 'Overdue'),
(1, 2, 2, NOW() - INTERVAL 20 DAY, NOW() - INTERVAL 5 DAY, NOW() - INTERVAL 4 DAY, 'Returned'),
(2, 1, 1, NOW() - INTERVAL 5 DAY, NOW() + INTERVAL 10 DAY, NULL, 'Borrowed'),
(2, 3, 3, NOW() - INTERVAL 7 DAY, NOW() + INTERVAL 7 DAY, NULL, 'Borrowed'),
(3, 4, 4, NOW() - INTERVAL 15 DAY, NOW() - INTERVAL 2 DAY, NULL, 'Overdue'),
(3, 5, 5, NOW() - INTERVAL 3 DAY, NOW() + INTERVAL 10 DAY, NULL, 'Borrowed'),
(3, 2, 2, NOW() - INTERVAL 30 DAY, NOW() - INTERVAL 10 DAY, NOW() - INTERVAL 8 DAY, 'Returned'),
(4, 3, 1, NOW() - INTERVAL 12 DAY, NOW() + INTERVAL 5 DAY, NULL, 'Borrowed'),
(5, 4, 2, NOW() - INTERVAL 2 DAY, NOW() + INTERVAL 15 DAY, NULL, 'Borrowed'),
(6, 1, 3, NOW() - INTERVAL 9 DAY, NOW() + INTERVAL 4 DAY, NULL, 'Borrowed');

-- ============================
-- TRIGGERS
-- ============================

DELIMITER $$

-- Prevent a book from being borrowed twice
CREATE TRIGGER trg_no_double_borrow
BEFORE INSERT ON Borrow
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Borrow
        WHERE book_id = NEW.book_id
        AND status = 'Borrowed'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This book is already borrowed.';
    END IF;
END$$

-- Auto-update overdue status
CREATE TRIGGER trg_auto_overdue
BEFORE UPDATE ON Borrow
FOR EACH ROW
BEGIN
    IF NEW.return_date IS NULL
       AND NEW.due_date < NOW()
       AND NEW.status = 'Borrowed'
    THEN
        SET NEW.status = 'Overdue';
    END IF;
END$$

DELIMITER ;

-- ============================
-- STORED PROCEDURES
-- ============================

DELIMITER $$

CREATE PROCEDURE sp_borrow_book(
    IN p_member INT,
    IN p_book INT,
    IN p_librarian INT
)
BEGIN
    INSERT INTO Borrow(member_id, book_id, librarian_id, due_date)
    VALUES (p_member, p_book, p_librarian, DATE_ADD(NOW(), INTERVAL 14 DAY));
END$$

CREATE PROCEDURE sp_return_book(
    IN p_borrow_id INT
)
BEGIN
    UPDATE Borrow
    SET return_date = NOW(),
        status = 'Returned'
    WHERE borrow_id = p_borrow_id;
END$$

DELIMITER ;
