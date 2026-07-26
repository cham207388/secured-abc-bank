INSERT INTO customer (name, email, mobile_number, pwd, role, create_dt)
VALUES ('Happy',
        'happy@example.com',
        '5334122365',
        '{bcrypt}$2a$12$88.f6upbBvy0okEa7OfHFuorV29qeK.sVbB9VQ6J6dWM1bW6Qef8m',
        'admin',
        CURRENT_DATE);

INSERT INTO accounts (customer_id, account_number, account_type, branch_address, create_dt)
VALUES (1, 1865764534, 'Savings', '123 Main Street, New York', CURRENT_DATE);

INSERT INTO account_transactions (transaction_id,
                                  account_number,
                                  customer_id,
                                  transaction_dt,
                                  transaction_summary,
                                  transaction_type,
                                  transaction_amt,
                                  closing_balance,
                                  create_dt)
VALUES (gen_random_uuid()::text, 1865764534, 1, CURRENT_DATE - INTERVAL '7 days', 'Coffee Shop', 'Withdrawal', 30,
        34500, CURRENT_DATE - INTERVAL '7 days'),
       (gen_random_uuid()::text, 1865764534, 1, CURRENT_DATE - INTERVAL '6 days', 'Uber', 'Withdrawal', 100, 34400,
        CURRENT_DATE - INTERVAL '6 days'),
       (gen_random_uuid()::text, 1865764534, 1, CURRENT_DATE - INTERVAL '5 days', 'Self Deposit', 'Deposit', 500, 34900,
        CURRENT_DATE - INTERVAL '5 days'),
       (gen_random_uuid()::text, 1865764534, 1, CURRENT_DATE - INTERVAL '4 days', 'Ebay', 'Withdrawal', 600, 34300,
        CURRENT_DATE - INTERVAL '4 days'),
       (gen_random_uuid()::text, 1865764534, 1, CURRENT_DATE - INTERVAL '2 days', 'OnlineTransfer', 'Deposit', 700,
        35000, CURRENT_DATE - INTERVAL '2 days'),
       (gen_random_uuid()::text, 1865764534, 1, CURRENT_DATE - INTERVAL '1 day', 'Amazon.com', 'Withdrawal', 100, 34900,
        CURRENT_DATE - INTERVAL '1 day');

INSERT INTO loans (customer_id, start_dt, loan_type, total_loan, amount_paid, outstanding_amount, create_dt)
VALUES (1, '2020-10-13', 'Home', 200000, 50000, 150000, '2020-10-13'),
       (1, '2020-06-06', 'Vehicle', 40000, 10000, 30000, '2020-06-06'),
       (1, '2018-02-14', 'Home', 50000, 10000, 40000, '2018-02-14'),
       (1, '2018-02-14', 'Personal', 10000, 3500, 6500, '2018-02-14');

INSERT INTO cards (card_number, customer_id, card_type, total_limit, amount_used, available_amount, create_dt)
VALUES ('4565XXXX4656', 1, 'Credit', 10000, 500, 9500, CURRENT_DATE),
       ('3455XXXX8673', 1, 'Credit', 7500, 600, 6900, CURRENT_DATE),
       ('2359XXXX9346', 1, 'Credit', 20000, 4000, 16000, CURRENT_DATE);

INSERT INTO notice_details (notice_summary, notice_details, notic_beg_dt, notic_end_dt, create_dt, update_dt)
VALUES ('Home Loan Interest rates reduced',
        'Home loan interest rates are reduced as per the goverment guidelines. The updated rates will be effective immediately',
        CURRENT_DATE - INTERVAL '30 days',
        CURRENT_DATE + INTERVAL '30 days',
        CURRENT_DATE,
        NULL),
       ('Net Banking Offers',
        'Customers who will opt for Internet banking while opening a saving account will get a $50 amazon voucher',
        CURRENT_DATE - INTERVAL '30 days',
        CURRENT_DATE + INTERVAL '30 days',
        CURRENT_DATE,
        NULL),
       ('Mobile App Downtime',
        'The mobile application of the SecuredBank will be down from 2AM-5AM on 12/05/2020 due to maintenance activities',
        CURRENT_DATE - INTERVAL '30 days',
        CURRENT_DATE + INTERVAL '30 days',
        CURRENT_DATE,
        NULL),
       ('E Auction notice',
        'There will be a e-auction on 12/08/2020 on the SecuredBank website for all the stubborn arrears.Interested parties can participate in the e-auction',
        CURRENT_DATE - INTERVAL '30 days',
        CURRENT_DATE + INTERVAL '30 days',
        CURRENT_DATE,
        NULL),
       ('Launch of Millennia Cards',
        'Millennia Credit Cards are launched for the premium customers of SecuredBank. With these cards, you will get 5% cashback for each purchase',
        CURRENT_DATE - INTERVAL '30 days',
        CURRENT_DATE + INTERVAL '30 days',
        CURRENT_DATE,
        NULL),
       ('COVID-19 Insurance',
        'SecuredBank launched an insurance policy which will cover COVID-19 expenses. Please reach out to the branch for more details',
        CURRENT_DATE - INTERVAL '30 days',
        CURRENT_DATE + INTERVAL '30 days',
        CURRENT_DATE,
        NULL);
