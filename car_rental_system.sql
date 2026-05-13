CREATE DATABASE car_rental_system;
USE car_rental_system;

-- ================================
-- 1. BRANCH
-- ================================
CREATE TABLE Branch (
    branch_id INT PRIMARY KEY AUTO_INCREMENT,
    branch_name VARCHAR(100),
    location VARCHAR(100)
);

-- ================================
-- 2. CUSTOMER
-- ================================
CREATE TABLE Customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    phone_number VARCHAR(15),
    email VARCHAR(100),
    address TEXT,
    aadhaar_number VARCHAR(20) UNIQUE,
    driving_license_number VARCHAR(50) UNIQUE,
    blacklist_status BOOLEAN DEFAULT FALSE,

    CHECK (phone_number IS NULL OR LENGTH(phone_number) BETWEEN 10 AND 15),
    CHECK (email LIKE '%@%.%')
);

-- ================================
-- 3. CAR
-- ================================
CREATE TABLE Car (
    car_id INT PRIMARY KEY AUTO_INCREMENT,
    registration_number VARCHAR(20) UNIQUE,
    brand VARCHAR(50),
    model VARCHAR(50),
    year INT,
    car_type VARCHAR(20),
    fuel_type VARCHAR(20),
    transmission_type VARCHAR(20),
    engine_capacity INT,
    horsepower INT,
    torque INT,
    airbags_count INT,
    mileage DECIMAL(5,2),
    battery_range DECIMAL(5,2),
    purpose_type VARCHAR(20),
    price_per_day DECIMAL(10,2),
    price_per_hour DECIMAL(10,2),
    security_deposit DECIMAL(10,2),
    status VARCHAR(20),
    branch_id INT,

    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id),

    CHECK (year >= 2000),
    CHECK (price_per_day > 0 AND price_per_hour > 0),
    CHECK (status IN ('Available','Booked','Maintenance'))
);

-- ================================
-- 4. EMPLOYEE
-- ================================
CREATE TABLE Employee (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    role VARCHAR(50),
    phone VARCHAR(15),
    branch_id INT,

    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id)
);

-- ================================
-- 5. BOOKING
-- ================================
CREATE TABLE Booking (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    car_id INT,
    booking_date DATE,
    start_datetime DATETIME,
    end_datetime DATETIME,
    total_hours INT,
    total_days INT,
    advance_payment DECIMAL(10,2),
    caution_deposit DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    fine_amount DECIMAL(10,2),
    final_amount DECIMAL(10,2),
    booking_status VARCHAR(20),

    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (car_id) REFERENCES Car(car_id),

    CHECK (end_datetime > start_datetime),
    CHECK (total_amount >= 0 AND final_amount >= 0)
);

-- ================================
-- 6. PAYMENT
-- ================================
CREATE TABLE Payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT,
    payment_method VARCHAR(20),
    payment_date DATE,
    amount_paid DECIMAL(10,2),
    payment_status VARCHAR(20),

    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id),

    CHECK (amount_paid > 0),
    CHECK (payment_status IN ('Paid','Pending','Failed'))
);

-- ================================
-- 7. MAINTENANCE
-- ================================
CREATE TABLE Maintenance (
    maintenance_id INT PRIMARY KEY AUTO_INCREMENT,
    car_id INT,
    service_date DATE,
    service_type VARCHAR(50),
    description TEXT,
    service_cost DECIMAL(10,2),
    service_center VARCHAR(100),
    next_service_date DATE,

    FOREIGN KEY (car_id) REFERENCES Car(car_id),

    CHECK (service_cost >= 0)
);

-- ================================
-- 8. INSPECTION
-- ================================
CREATE TABLE Inspection (
    inspection_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT,
    car_id INT,
    inspection_type VARCHAR(20),
    fuel_level DECIMAL(5,2),
    odometer_reading INT,
    damage_notes TEXT,
    image_proof VARCHAR(255),

    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id),
    FOREIGN KEY (car_id) REFERENCES Car(car_id),

    CHECK (fuel_level >= 0 AND fuel_level <= 100)
);

-- ================================
-- SAMPLE DATA
-- ================================

INSERT INTO Branch (branch_name, location)
VALUES ('Vijayawada Branch', 'Vijayawada');

INSERT INTO Customer (name, phone_number, email, address, aadhaar_number, driving_license_number)
VALUES ('Sai Akhil', '9876543210', 'akhil@gmail.com', 'AP', '123456789012', 'DL12345');

INSERT INTO Car (registration_number, brand, model, year, car_type, fuel_type, transmission_type,
engine_capacity, horsepower, torque, airbags_count, mileage, purpose_type,
price_per_day, price_per_hour, security_deposit, status, branch_id)
VALUES ('AP16AB1234', 'Toyota', 'Innova', 2022, 'SUV', 'Diesel', 'Manual',
2400, 150, 350, 6, 15.0, 'Highway',
2500, 200, 10000, 'Available', 1);

INSERT INTO Booking (customer_id, car_id, booking_date, start_datetime, end_datetime,
total_days, advance_payment, caution_deposit, total_amount, final_amount, booking_status)
VALUES (1, 1, CURDATE(), '2026-04-20 10:00:00', '2026-04-23 10:00:00',
3, 2000, 10000, 7500, 5500, 'Confirmed');

INSERT INTO Payment (booking_id, payment_method, payment_date, amount_paid, payment_status)
VALUES (1, 'UPI', CURDATE(), 2000, 'Paid');

-- ================================
-- VIEWS
-- ================================

-- Available Cars
CREATE VIEW vw_available_cars AS
SELECT car_id, brand, model, price_per_day
FROM Car
WHERE status = 'Available';

-- Booking Details
CREATE VIEW vw_booking_details AS
SELECT 
    b.booking_id,
    c.name AS customer_name,
    car.brand,
    car.model,
    b.start_datetime,
    b.end_datetime,
    b.final_amount,
    b.booking_status
FROM Booking b
JOIN Customer c ON b.customer_id = c.customer_id
JOIN Car car ON b.car_id = car.car_id;

-- Payment Summary
CREATE VIEW vw_payment_summary AS
SELECT 
    p.payment_id,
    b.booking_id,
    p.amount_paid,
    p.payment_method,
    p.payment_status
FROM Payment p
JOIN Booking b ON p.booking_id = b.booking_id;

-- Maintenance History
CREATE VIEW vw_maintenance_history AS
SELECT 
    c.registration_number,
    m.service_date,
    m.service_type,
    m.service_cost
FROM Maintenance m
JOIN Car c ON m.car_id = c.car_id;

-- Inspection Report
CREATE VIEW vw_inspection_report AS
SELECT 
    i.inspection_id,
    b.booking_id,
    i.inspection_type,
    i.fuel_level,
    i.odometer_reading
FROM Inspection i
JOIN Booking b ON i.booking_id = b.booking_id;


SELECT c.name, c.driving_license_number
FROM Customer c
JOIN Booking b ON c.customer_id = b.customer_id
JOIN Car a ON b.car_id = a.car_id
WHERE a.brand = 'Toyota'
AND b.final_amount > 1000;

INSERT INTO Booking (customer_id, car_id, booking_date, start_datetime, end_datetime,
total_days, advance_payment, caution_deposit, total_amount, final_amount, booking_status)
VALUES (3, 24, CURDATE(), '2026-04-25 12:30:00', '2026-04-26 15:00:00',
3, 2000, 10000, 7500, 5500, 'Confirmed');

