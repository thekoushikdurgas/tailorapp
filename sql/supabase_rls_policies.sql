-- Row Level Security (RLS) Policies for TailorApp
-- Comprehensive security policies for the tailoring platform

-- Enable RLS on all tables
ALTER TABLE USERS ENABLE ROW LEVEL SECURITY;

ALTER TABLE CUSTOMERS ENABLE ROW LEVEL SECURITY;

ALTER TABLE TAILORS ENABLE ROW LEVEL SECURITY;

ALTER TABLE ADMINS ENABLE ROW LEVEL SECURITY;

ALTER TABLE ORDERS ENABLE ROW LEVEL SECURITY;

ALTER TABLE GARMENTS ENABLE ROW LEVEL SECURITY;

ALTER TABLE FABRICS ENABLE ROW LEVEL SECURITY;

ALTER TABLE PATTERNS ENABLE ROW LEVEL SECURITY;

ALTER TABLE AI_SUGGESTIONS ENABLE ROW LEVEL SECURITY;

ALTER TABLE MEASUREMENTS ENABLE ROW LEVEL SECURITY;

ALTER TABLE CHATS ENABLE ROW LEVEL SECURITY;

ALTER TABLE CHAT_MESSAGES ENABLE ROW LEVEL SECURITY;

ALTER TABLE NOTIFICATIONS ENABLE ROW LEVEL SECURITY;

ALTER TABLE ADMIN_ACTIVITY_LOGS ENABLE ROW LEVEL SECURITY;

-- Users table policies
-- Users can read and update their own profile
CREATE POLICY "Users can view own profile" ON USERS
    FOR SELECT USING (AUTH.UID() = ID);

CREATE POLICY "Users can update own profile" ON USERS
    FOR UPDATE USING (AUTH.UID() = ID);

CREATE POLICY "Users can insert own profile" ON USERS
    FOR INSERT WITH CHECK (AUTH.UID() = ID);

-- Customers table policies
-- Allow users to read and write their own customer profile
CREATE POLICY "Customers can view own profile" ON CUSTOMERS
    FOR SELECT USING (
        AUTH.UID() IN (
    SELECT
                  ID
    FROM
                  USERS
    WHERE
                  USERS.ID = CUSTOMERS.USER_ID
)
    );

CREATE POLICY "Customers can update own profile" ON CUSTOMERS
    FOR UPDATE USING (
        AUTH.UID() IN (
    SELECT
                  ID
    FROM
                  USERS
    WHERE
                  USERS.ID = CUSTOMERS.USER_ID
)
    );

CREATE POLICY "Customers can insert own profile" ON CUSTOMERS
    FOR INSERT WITH CHECK (
        AUTH.UID() IN (
    SELECT
                  ID
    FROM
                  USERS
    WHERE
                  USERS.ID = CUSTOMERS.USER_ID
)
    );

-- Orders table policies
-- Allow users to read and write their own orders
CREATE POLICY "Users can view own orders" ON ORDERS
    FOR SELECT USING (
        AUTH.UID() IN (
    SELECT
                  USER_ID
    FROM
                  CUSTOMERS
    WHERE
                  CUSTOMERS.ID = ORDERS.CUSTOMER_ID
) OR
        AUTH.UID() IN (
    SELECT
                  USER_ID
    FROM
                  TAILORS
    WHERE
                  TAILORS.ID = ORDERS.TAILOR_ID
)
    );

CREATE POLICY "Users can update own orders" ON ORDERS
    FOR UPDATE USING (
        AUTH.UID() IN (
    SELECT
                  USER_ID
    FROM
                  CUSTOMERS
    WHERE
                  CUSTOMERS.ID = ORDERS.CUSTOMER_ID
) OR
        AUTH.UID() IN (
    SELECT
                  USER_ID
    FROM
                  TAILORS
    WHERE
                  TAILORS.ID = ORDERS.TAILOR_ID
)
    );

CREATE POLICY "Users can create orders" ON ORDERS
    FOR INSERT WITH CHECK (
        AUTH.UID() IN (
    SELECT
                  USER_ID
    FROM
                  CUSTOMERS
    WHERE
                  CUSTOMERS.ID = ORDERS.CUSTOMER_ID
)
    );

-- Garments table policies
-- Allow users to read and write their own garments
CREATE POLICY "Users can view own garments" ON GARMENTS
    FOR SELECT USING (
        AUTH.UID() IN (
    SELECT
                  USER_ID
    FROM
                  CUSTOMERS
    WHERE
                  CUSTOMERS.ID = GARMENTS.CUSTOMER_ID
)
    );

CREATE POLICY "Users can update own garments" ON GARMENTS
    FOR UPDATE USING (
        AUTH.UID() IN (
    SELECT
                  USER_ID
    FROM
                  CUSTOMERS
    WHERE
                  CUSTOMERS.ID = GARMENTS.CUSTOMER_ID
)
    );

CREATE POLICY "Users can create garments" ON GARMENTS
    FOR INSERT WITH CHECK (
        AUTH.UID() IN (
    SELECT
                  USER_ID
    FROM
                  CUSTOMERS
    WHERE
                  CUSTOMERS.ID = GARMENTS.CUSTOMER_ID
)
    );

-- AI Suggestions table policies
-- Allow users to read and write their own AI suggestions
CREATE POLICY "Users can view own ai_suggestions" ON AI_SUGGESTIONS
    FOR SELECT USING (
        AUTH.UID() IN (
    SELECT
                  USER_ID
    FROM
                  CUSTOMERS
    WHERE
                  CUSTOMERS.ID = AI_SUGGESTIONS.CUSTOMER_ID
)
    );

CREATE POLICY "Users can update own ai_suggestions" ON AI_SUGGESTIONS
    FOR UPDATE USING (
        AUTH.UID() IN (
    SELECT
                  USER_ID
    FROM
                  CUSTOMERS
    WHERE
                  CUSTOMERS.ID = AI_SUGGESTIONS.CUSTOMER_ID
)
    );

CREATE POLICY "Users can create ai_suggestions" ON AI_SUGGESTIONS
    FOR INSERT WITH CHECK (
        AUTH.UID() IN (
    SELECT
                  USER_ID
    FROM
                  CUSTOMERS
    WHERE
                  CUSTOMERS.ID = AI_SUGGESTIONS.CUSTOMER_ID
)
    );

-- Measurements table policies
-- Allow users to read and write their own measurements
CREATE POLICY "Users can view own measurements" ON MEASUREMENTS
    FOR SELECT USING (
        AUTH.UID() IN (
    SELECT
                  USER_ID
    FROM
                  CUSTOMERS
    WHERE
                  CUSTOMERS.ID = MEASUREMENTS.CUSTOMER_ID
)
    );

CREATE POLICY "Users can update own measurements" ON MEASUREMENTS
    FOR UPDATE USING (
        AUTH.UID() IN (
    SELECT
                  USER_ID
    FROM
                  CUSTOMERS
    WHERE
                  CUSTOMERS.ID = MEASUREMENTS.CUSTOMER_ID
)
    );

CREATE POLICY "Users can create measurements" ON MEASUREMENTS
    FOR INSERT WITH CHECK (
        AUTH.UID() IN (
    SELECT
                  USER_ID
    FROM
                  CUSTOMERS
    WHERE
                  CUSTOMERS.ID = MEASUREMENTS.CUSTOMER_ID
)
    );

-- Fabrics table policies (public read access for authenticated users)
CREATE POLICY "Authenticated users can view fabrics" ON FABRICS
    FOR SELECT USING (AUTH.ROLE() = 'authenticated');

-- Only admins can modify fabrics
CREATE POLICY "Admins can modify fabrics" ON FABRICS
    FOR ALL USING (
        AUTH.UID() IN (
    SELECT
                  USER_ID
    FROM
                  ADMINS
    WHERE
                  ADMINS.USER_ID = AUTH.UID()
)
    );

-- Patterns table policies (public read access for authenticated users)
CREATE POLICY "Authenticated users can view patterns" ON PATTERNS
    FOR SELECT USING (AUTH.ROLE() = 'authenticated');

CREATE POLICY "Users can create own patterns" ON PATTERNS
    FOR INSERT WITH CHECK (AUTH.UID() = CREATED_BY);

CREATE POLICY "Users can update own patterns" ON PATTERNS
    FOR UPDATE USING (AUTH.UID() = CREATED_BY);

-- Tailors table policies
-- Authenticated users can read tailor profiles for selection
CREATE POLICY "Authenticated users can view tailors" ON TAILORS
    FOR SELECT USING (AUTH.ROLE() = 'authenticated');

-- Tailors can update their own profile
CREATE POLICY "Tailors can update own profile" ON TAILORS
    FOR UPDATE USING (
        AUTH.UID() IN (
    SELECT
                  ID
    FROM
                  USERS
    WHERE
                  USERS.ID = TAILORS.USER_ID
)
    );

CREATE POLICY "Tailors can insert own profile" ON TAILORS
    FOR INSERT WITH CHECK (
        AUTH.UID() IN (
    SELECT
                  ID
    FROM
                  USERS
    WHERE
                  USERS.ID = TAILORS.USER_ID
)
    );

-- Admins table policies
-- Admin-only access for admin documents
CREATE POLICY "Admins can view admin profiles" ON ADMINS
    FOR SELECT USING (
        AUTH.UID() IN (
    SELECT
                  USER_ID
    FROM
                  ADMINS
    WHERE
                  ADMINS.USER_ID = AUTH.UID()
)
    );

CREATE POLICY "Admins can update own profile" ON ADMINS
    FOR UPDATE USING (
        AUTH.UID() IN (
    SELECT
                  ID
    FROM
                  USERS
    WHERE
                  USERS.ID = ADMINS.USER_ID
)
    );

CREATE POLICY "Admins can insert own profile" ON ADMINS
    FOR INSERT WITH CHECK (
        AUTH.UID() IN (
    SELECT
                  ID
    FROM
                  USERS
    WHERE
                  USERS.ID = ADMINS.USER_ID
)
    );

-- Chats table policies
-- Allow authenticated users to create and manage their own chat messages
CREATE POLICY "Users can view own chats" ON CHATS
    FOR SELECT USING (
        AUTH.UID() = ANY(PARTICIPANTS)
    );

CREATE POLICY "Users can update own chats" ON CHATS
    FOR UPDATE USING (
        AUTH.UID() = ANY(PARTICIPANTS)
    );

CREATE POLICY "Users can create chats" ON CHATS
    FOR INSERT WITH CHECK (
        AUTH.UID() = ANY(PARTICIPANTS)
    );

-- Chat Messages table policies
CREATE POLICY "Users can view chat messages" ON CHAT_MESSAGES
    FOR SELECT USING (
        AUTH.UID() IN (
    SELECT
                  UNNEST(PARTICIPANTS)
    FROM
                  CHATS
    WHERE
                  CHATS.ID = CHAT_MESSAGES.CHAT_ID
)
    );

CREATE POLICY "Users can create chat messages" ON CHAT_MESSAGES
    FOR INSERT WITH CHECK (
        AUTH.UID() = SENDER_ID AND
        AUTH.UID() IN (
    SELECT
                  UNNEST(PARTICIPANTS)
    FROM
                  CHATS
    WHERE
                  CHATS.ID = CHAT_MESSAGES.CHAT_ID
)
    );

CREATE POLICY "Users can update own messages" ON CHAT_MESSAGES
    FOR UPDATE USING (AUTH.UID() = SENDER_ID);

-- Notifications table policies
-- Allow users to read and write their own notifications
CREATE POLICY "Users can view own notifications" ON NOTIFICATIONS
    FOR SELECT USING (AUTH.UID() = USER_ID);

CREATE POLICY "Users can update own notifications" ON NOTIFICATIONS
    FOR UPDATE USING (AUTH.UID() = USER_ID);

CREATE POLICY "System can create notifications" ON NOTIFICATIONS
    FOR INSERT WITH CHECK (TRUE);

-- Allow system to create notifications

-- Admin Activity Logs policies
-- Only admins can view admin activity logs
CREATE POLICY "Admins can view activity logs" ON ADMIN_ACTIVITY_LOGS
    FOR SELECT USING (
        AUTH.UID() IN (
    SELECT
                  USER_ID
    FROM
                  ADMINS
    WHERE
                  ADMINS.USER_ID = AUTH.UID()
)
    );

CREATE POLICY "System can create activity logs" ON ADMIN_ACTIVITY_LOGS
    FOR INSERT WITH CHECK (TRUE);

-- Allow system to create logs

-- Storage policies for avatars bucket
CREATE POLICY "Users can upload own avatar" ON STORAGE.OBJECTS
    FOR INSERT WITH CHECK (
        BUCKET_ID = 'avatars' AND
        AUTH.ROLE() = 'authenticated' AND
        (STORAGE.FOLDERNAME(NAME))[1] = AUTH.UID()::TEXT
    );

CREATE POLICY "Users can view avatars" ON STORAGE.OBJECTS
    FOR SELECT USING (
        BUCKET_ID = 'avatars' AND
        AUTH.ROLE() = 'authenticated'
    );

CREATE POLICY "Users can update own avatar" ON STORAGE.OBJECTS
    FOR UPDATE USING (
        BUCKET_ID = 'avatars' AND
        AUTH.ROLE() = 'authenticated' AND
        (STORAGE.FOLDERNAME(NAME))[1] = AUTH.UID()::TEXT
    );

CREATE POLICY "Users can delete own avatar" ON STORAGE.OBJECTS
    FOR DELETE USING (
        BUCKET_ID = 'avatars' AND
        AUTH.ROLE() = 'authenticated' AND
        (STORAGE.FOLDERNAME(NAME))[1] = AUTH.UID()::TEXT
    );