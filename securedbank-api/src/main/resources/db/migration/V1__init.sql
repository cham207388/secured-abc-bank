-- Create customer table
CREATE TABLE customer (
    customer_id SERIAL NOT NULL,
    name varchar(100) NOT NULL,
    email varchar(100) NOT NULL,
    mobile_number varchar(20) NOT NULL,
    pwd varchar(500) NOT NULL,
    role varchar(100) NOT NULL,
    create_dt date DEFAULT NULL,
    PRIMARY KEY (customer_id)
);

-- Create accounts table
CREATE TABLE accounts (
    customer_id int NOT NULL,
    account_number int NOT NULL,
    account_type varchar(100) NOT NULL,
    branch_address varchar(200) NOT NULL,
    create_dt date DEFAULT NULL,
    PRIMARY KEY (account_number),
    CONSTRAINT customer_ibfk_1 FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON DELETE CASCADE
);

-- Create account_transactions table
CREATE TABLE account_transactions (
    transaction_id varchar(200) NOT NULL,
    account_number int NOT NULL,
    customer_id int NOT NULL,
    transaction_dt date NOT NULL,
    transaction_summary varchar(200) NOT NULL,
    transaction_type varchar(100) NOT NULL,
    transaction_amt int NOT NULL,
    closing_balance int NOT NULL,
    create_dt date DEFAULT NULL,
    PRIMARY KEY (transaction_id),
    CONSTRAINT accounts_ibfk_2 FOREIGN KEY (account_number) REFERENCES accounts (account_number) ON DELETE CASCADE,
    CONSTRAINT acct_user_ibfk_1 FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON DELETE CASCADE
);

-- Create loans table
CREATE TABLE loans (
    loan_number SERIAL NOT NULL,
    customer_id int NOT NULL,
    start_dt date NOT NULL,
    loan_type varchar(100) NOT NULL,
    total_loan int NOT NULL,
    amount_paid int NOT NULL,
    outstanding_amount int NOT NULL,
    create_dt date DEFAULT NULL,
    PRIMARY KEY (loan_number),
    CONSTRAINT loan_customer_ibfk_1 FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON DELETE CASCADE
);

-- Create cards table
CREATE TABLE cards (
    card_id SERIAL NOT NULL,
    card_number varchar(100) NOT NULL,
    customer_id int NOT NULL,
    card_type varchar(100) NOT NULL,
    total_limit int NOT NULL,
    amount_used int NOT NULL,
    available_amount int NOT NULL,
    create_dt date DEFAULT NULL,
    PRIMARY KEY (card_id),
    CONSTRAINT card_customer_ibfk_1 FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON DELETE CASCADE
);

-- Create notice_details table
CREATE TABLE notice_details (
    notice_id SERIAL NOT NULL,
    notice_summary varchar(200) NOT NULL,
    notice_details varchar(500) NOT NULL,
    notic_beg_dt date NOT NULL,
    notic_end_dt date DEFAULT NULL,
    create_dt date DEFAULT NULL,
    update_dt date DEFAULT NULL,
    PRIMARY KEY (notice_id)
);

-- Create contact_messages table
CREATE TABLE contact_messages (
    contact_id varchar(50) NOT NULL,
    contact_name varchar(50) NOT NULL,
    contact_email varchar(100) NOT NULL,
    subject varchar(500) NOT NULL,
    message varchar(2000) NOT NULL,
    create_dt date DEFAULT NULL,
    PRIMARY KEY (contact_id)
);
