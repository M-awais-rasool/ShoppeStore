-- SQL Server Initialization for ShoppeStore

-- Create the database if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'ShoppeStore')
BEGIN
    CREATE DATABASE ShoppeStore;
END
GO

USE ShoppeStore;
GO

-- Create users table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'users')
BEGIN
    CREATE TABLE users (
        id NVARCHAR(36) PRIMARY KEY,
        name NVARCHAR(100) NOT NULL,
        email NVARCHAR(100) UNIQUE NOT NULL,
        password NVARCHAR(255) NOT NULL,
        image NVARCHAR(MAX) NULL
    );
END
GO

-- Create products table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'products')
BEGIN
    CREATE TABLE products (
        id NVARCHAR(36) PRIMARY KEY,
        name NVARCHAR(100) NOT NULL,
        image NVARCHAR(MAX) NOT NULL,
        description NVARCHAR(MAX) NOT NULL,
        price FLOAT NOT NULL,
        quantity INT NOT NULL,
        isWishlist BIT NOT NULL DEFAULT 0,
        category NVARCHAR(50) NOT NULL
    );
END
GO

-- Create address table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'address')
BEGIN
    CREATE TABLE address (
        id NVARCHAR(36) PRIMARY KEY,
        userID NVARCHAR(36) NOT NULL,
        name NVARCHAR(100) NOT NULL,
        address NVARCHAR(255) NOT NULL,
        apartment NVARCHAR(100) NULL,
        phone NVARCHAR(20) NOT NULL,
        city NVARCHAR(100) NOT NULL,
        district NVARCHAR(100) NOT NULL,
        FOREIGN KEY (userID) REFERENCES users(id) ON DELETE CASCADE
    );
END
GO

-- Create cart table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'cart')
BEGIN
    CREATE TABLE cart (
        id NVARCHAR(36) PRIMARY KEY,
        userID NVARCHAR(36) NOT NULL,
        productID NVARCHAR(36) NOT NULL,
        quantity INT NOT NULL,
        size NVARCHAR(5) NOT NULL,
        FOREIGN KEY (userID) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (productID) REFERENCES products(id) ON DELETE CASCADE
    );
END
GO

-- Create wishlist table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'wishlist')
BEGIN
    CREATE TABLE wishlist (
        id NVARCHAR(36) PRIMARY KEY,
        userID NVARCHAR(36) NOT NULL,
        productID NVARCHAR(36) NOT NULL,
        image NVARCHAR(MAX) NOT NULL,
        name NVARCHAR(100) NOT NULL,
        price FLOAT NOT NULL,
        size NVARCHAR(5) NOT NULL,
        FOREIGN KEY (userID) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (productID) REFERENCES products(id) ON DELETE CASCADE
    );
END
GO

-- Create orders table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'orders')
BEGIN
    CREATE TABLE orders (
        id NVARCHAR(36) PRIMARY KEY,
        orderID NVARCHAR(36) NOT NULL UNIQUE,
        userID NVARCHAR(36) NOT NULL,
        totalPrice FLOAT NOT NULL,
        status NVARCHAR(20) NOT NULL DEFAULT 'Pending',
        DeliveryStatus NVARCHAR(50) NOT NULL,
        orderDate DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (userID) REFERENCES users(id) ON DELETE CASCADE
    );
END
GO

-- Create orderItems table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'orderItems')
BEGIN
    CREATE TABLE orderItems (
        id NVARCHAR(36) PRIMARY KEY,
        orderID NVARCHAR(36) NOT NULL,
        productID NVARCHAR(36) NOT NULL,
        image NVARCHAR(MAX) NOT NULL,
        name NVARCHAR(100) NOT NULL,
        quantity INT NOT NULL,
        price FLOAT NOT NULL,
        size NVARCHAR(5) NOT NULL,
        FOREIGN KEY (orderID) REFERENCES orders(orderID)
    );
END
GO

-- Insert sample products
IF NOT EXISTS (SELECT TOP 1 * FROM products)
BEGIN
    INSERT INTO products (id, name, image, description, price, quantity, isWishlist, category)
    VALUES 
    (NEWID(), 'White T-Shirt', 'https://products-api-dynamic.s3.eu-west-2.amazonaws.com/tshirt-white.jpg', 'Classic white cotton t-shirt with round neck', 19.99, 100, 0, 'T-Shirts'),
    (NEWID(), 'Black T-Shirt', 'https://products-api-dynamic.s3.eu-west-2.amazonaws.com/tshirt-black.jpg', 'Classic black cotton t-shirt with round neck', 19.99, 100, 0, 'T-Shirts'),
    (NEWID(), 'Blue Jeans', 'https://products-api-dynamic.s3.eu-west-2.amazonaws.com/jeans-blue.jpg', 'Classic blue denim jeans with straight cut', 49.99, 50, 0, 'Jeans'),
    (NEWID(), 'Black Jeans', 'https://products-api-dynamic.s3.eu-west-2.amazonaws.com/jeans-black.jpg', 'Classic black denim jeans with slim fit', 49.99, 50, 0, 'Jeans'),
    (NEWID(), 'Red Hoodie', 'https://products-api-dynamic.s3.eu-west-2.amazonaws.com/hoodie-red.jpg', 'Warm and comfortable red hoodie with front pocket', 39.99, 30, 0, 'Hoodies'),
    (NEWID(), 'Gray Hoodie', 'https://products-api-dynamic.s3.eu-west-2.amazonaws.com/hoodie-gray.jpg', 'Warm and comfortable gray hoodie with front pocket', 39.99, 30, 0, 'Hoodies'),
    (NEWID(), 'Summer Shorts', 'https://products-api-dynamic.s3.eu-west-2.amazonaws.com/shorts-summer.jpg', 'Comfortable cotton shorts perfect for summer', 29.99, 40, 0, 'Shorts'),
    (NEWID(), 'Sport Shorts', 'https://products-api-dynamic.s3.eu-west-2.amazonaws.com/shorts-sport.jpg', 'Lightweight sport shorts with elasticated waist', 24.99, 40, 0, 'Shorts'),
    (NEWID(), 'Leather Jacket', 'https://products-api-dynamic.s3.eu-west-2.amazonaws.com/jacket-leather.jpg', 'Classic black leather jacket with multiple pockets', 199.99, 15, 0, 'Jackets'),
    (NEWID(), 'Denim Jacket', 'https://products-api-dynamic.s3.eu-west-2.amazonaws.com/jacket-denim.jpg', 'Classic blue denim jacket with button closure', 89.99, 20, 0, 'Jackets');
END
GO
