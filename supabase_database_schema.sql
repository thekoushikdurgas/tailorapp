-- ============================================================================
-- TailorApp Database Schema for Supabase
-- Complete database schema for AI-powered tailoring platform
-- ============================================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- ENUMS
-- ============================================================================

-- User roles enum
CREATE TYPE USER_ROLE AS
    ENUM ('customer', 'tailor', 'admin', 'super_admin');
 
    -- Order status enum
    CREATE TYPE ORDER_STATUS AS
        ENUM ( 'draft', 'pending', 'confirmed', 'in_progress', 'measurements_taken', 'cutting', 'stitching', 'fitting_scheduled', 'alterations', 'quality_check', 'ready', 'delivered', 'completed', 'cancelled' );
 
        -- Payment status enum
        CREATE TYPE PAYMENT_STATUS AS
            ENUM ('pending', 'paid', 'partial', 'refunded', 'failed');
 
            -- Garment category enum
            CREATE TYPE GARMENT_CATEGORY AS
                ENUM ( 'shirt', 'pants', 'suit', 'dress', 'skirt', 'jacket', 'blouse', 'kurta', 'saree_blouse', 'traditional_wear', 'formal_wear' );
 
                -- Fabric type enum
                CREATE TYPE FABRIC_TYPE AS
                    ENUM ( 'cotton', 'silk', 'wool', 'linen', 'polyester', 'blend', 'denim', 'chiffon', 'georgette', 'velvet', 'other' );
 
                    -- Measurement unit enum
                    CREATE TYPE MEASUREMENT_UNIT AS
                        ENUM ('cm', 'inch');
 
                        -- Notification type enum
                        CREATE TYPE NOTIFICATION_TYPE AS
                            ENUM ( 'order_update', 'payment_reminder', 'appointment', 'promotion', 'system', 'chat_message' );
 
                            -- ============================================================================
                            -- CORE TABLES
                            -- ============================================================================
                            -- Users table (base user information)
                            CREATE TABLE USERS ( ID UUID PRIMARY KEY DEFAULT UUID_GENERATE_V4(), EMAIL VARCHAR(255) UNIQUE NOT NULL, PHONE VARCHAR(20) UNIQUE, FULL_NAME VARCHAR(255) NOT NULL, AVATAR_URL TEXT, ROLE USER_ROLE NOT NULL DEFAULT 'customer', IS_ACTIVE BOOLEAN DEFAULT TRUE, EMAIL_VERIFIED BOOLEAN DEFAULT FALSE, PHONE_VERIFIED BOOLEAN DEFAULT FALSE, ONBOARDING_COMPLETED BOOLEAN DEFAULT FALSE, CREATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW(), UPDATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW() );
 
                            -- Countries table for address support
                            CREATE TABLE COUNTRIES ( ID SERIAL PRIMARY KEY, NAME VARCHAR(255) NOT NULL, CODE VARCHAR(2) NOT NULL UNIQUE, PHONE_CODE VARCHAR(10), CURRENCY VARCHAR(3), CREATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW() );
 
                            -- User addresses
                            CREATE TABLE USER_ADDRESSES ( ID UUID PRIMARY KEY DEFAULT UUID_GENERATE_V4(), USER_ID UUID NOT NULL REFERENCES USERS(ID) ON DELETE CASCADE, ADDRESS_LINE1 VARCHAR(255) NOT NULL, ADDRESS_LINE2 VARCHAR(255), CITY VARCHAR(100) NOT NULL, STATE VARCHAR(100) NOT NULL, POSTAL_CODE VARCHAR(20) NOT NULL, COUNTRY_ID INTEGER NOT NULL REFERENCES COUNTRIES(ID), IS_PRIMARY BOOLEAN DEFAULT FALSE, CREATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW(), UPDATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW() );
 
                            -- Customer profiles
                            CREATE TABLE CUSTOMERS ( ID UUID PRIMARY KEY DEFAULT UUID_GENERATE_V4(), USER_ID UUID NOT NULL REFERENCES USERS(ID) ON DELETE CASCADE, DATE_OF_BIRTH DATE, GENDER VARCHAR(20), PREFERRED_LANGUAGE VARCHAR(10) DEFAULT 'en', STYLE_PREFERENCES JSONB DEFAULT '{}', FABRIC_PREFERENCES JSONB DEFAULT '{}', COLOR_PREFERENCES JSONB DEFAULT '{}', BUDGET_RANGE JSONB DEFAULT '{}', SPECIAL_NOTES TEXT, CREATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW(), UPDATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW() );
 
                            -- Tailor profiles
                            CREATE TABLE TAILORS ( ID UUID PRIMARY KEY DEFAULT UUID_GENERATE_V4(), USER_ID UUID NOT NULL REFERENCES USERS(ID) ON DELETE CASCADE, BUSINESS_NAME VARCHAR(255), LICENSE_NUMBER VARCHAR(100), EXPERIENCE_YEARS INTEGER DEFAULT 0, SPECIALIZATIONS JSONB DEFAULT '[]', AVAILABLE_SERVICES JSONB DEFAULT '[]', WORKING_HOURS JSONB DEFAULT '{}', RATING DECIMAL(3, 2) DEFAULT 0.00, TOTAL_ORDERS INTEGER DEFAULT 0, BUSINESS_ADDRESS_ID UUID REFERENCES USER_ADDRESSES(ID), VERIFICATION_STATUS VARCHAR(50) DEFAULT 'pending', VERIFICATION_DOCUMENTS JSONB DEFAULT '[]', CREATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW(), UPDATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW() );
 
                            -- Admin profiles
                            CREATE TABLE ADMINS ( ID UUID PRIMARY KEY DEFAULT UUID_GENERATE_V4(), USER_ID UUID NOT NULL REFERENCES USERS(ID) ON DELETE CASCADE, DEPARTMENT VARCHAR(100), PERMISSIONS JSONB DEFAULT '[]', ACCESS_LEVEL INTEGER DEFAULT 1, LAST_LOGIN TIMESTAMP WITH TIME ZONE, CREATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW(), UPDATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW() );
 
                            -- ============================================================================
                            -- PRODUCT & INVENTORY TABLES
                            -- ============================================================================
                            -- Fabrics catalog
                            CREATE TABLE FABRICS ( ID UUID PRIMARY KEY DEFAULT UUID_GENERATE_V4(), NAME VARCHAR(255) NOT NULL, TYPE FABRIC_TYPE NOT NULL, BRAND VARCHAR(100), COLOR VARCHAR(50), PATTERN VARCHAR(100), WEIGHT_GSM INTEGER, WIDTH_CM INTEGER, PRICE_PER_METER DECIMAL(10, 2), DESCRIPTION TEXT, CARE_INSTRUCTIONS TEXT, IMAGE_URLS JSONB DEFAULT '[]', PROPERTIES JSONB DEFAULT '{}', IS_AVAILABLE BOOLEAN DEFAULT TRUE, STOCK_QUANTITY INTEGER DEFAULT 0, CREATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW(), UPDATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW() );
 
                            -- Garment templates/patterns
                            CREATE TABLE GARMENT_TEMPLATES ( ID UUID PRIMARY KEY DEFAULT UUID_GENERATE_V4(), NAME VARCHAR(255) NOT NULL, CATEGORY GARMENT_CATEGORY NOT NULL, DESCRIPTION TEXT, DIFFICULTY_LEVEL INTEGER DEFAULT 1, ESTIMATED_TIME_HOURS INTEGER, FABRIC_REQUIREMENTS JSONB DEFAULT '{}', MEASUREMENTS_REQUIRED JSONB DEFAULT '[]', DESIGN_FEATURES JSONB DEFAULT '{}', BASE_PRICE DECIMAL(10, 2) DEFAULT 0.00, IMAGE_URLS JSONB DEFAULT '[]', PATTERN_FILES JSONB DEFAULT '[]', IS_ACTIVE BOOLEAN DEFAULT TRUE, CREATED_BY UUID REFERENCES USERS(ID), CREATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW(), UPDATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW() );
 
                            -- ============================================================================
                            -- ORDER MANAGEMENT TABLES
                            -- ============================================================================
                            -- Orders
                            CREATE TABLE ORDERS ( ID UUID PRIMARY KEY DEFAULT UUID_GENERATE_V4(), ORDER_NUMBER VARCHAR(50) UNIQUE NOT NULL, CUSTOMER_ID UUID NOT NULL REFERENCES CUSTOMERS(ID), TAILOR_ID UUID REFERENCES TAILORS(ID), STATUS ORDER_STATUS DEFAULT 'draft', PAYMENT_STATUS PAYMENT_STATUS DEFAULT 'pending', TOTAL_AMOUNT DECIMAL(10, 2) DEFAULT 0.00, ADVANCE_AMOUNT DECIMAL(10, 2) DEFAULT 0.00, BALANCE_AMOUNT DECIMAL(10, 2) DEFAULT 0.00, CURRENCY VARCHAR(3) DEFAULT 'USD', ESTIMATED_DELIVERY_DATE DATE, ACTUAL_DELIVERY_DATE DATE, SPECIAL_INSTRUCTIONS TEXT, ORDER_METADATA JSONB DEFAULT '{}', CREATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW(), UPDATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW() );
 
                            -- Order items (individual garments in an order)
                            CREATE TABLE ORDER_ITEMS ( ID UUID PRIMARY KEY DEFAULT UUID_GENERATE_V4(), ORDER_ID UUID NOT NULL REFERENCES ORDERS(ID) ON DELETE CASCADE, GARMENT_TEMPLATE_ID UUID REFERENCES GARMENT_TEMPLATES(ID), FABRIC_ID UUID REFERENCES FABRICS(ID), QUANTITY INTEGER DEFAULT 1, UNIT_PRICE DECIMAL(10, 2) DEFAULT 0.00, TOTAL_PRICE DECIMAL(10, 2) DEFAULT 0.00, CUSTOM_SPECIFICATIONS JSONB DEFAULT '{}', MEASUREMENTS JSONB DEFAULT '{}', NOTES TEXT, STATUS VARCHAR(50) DEFAULT 'pending', CREATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW(), UPDATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW() );
 
                            -- Customer measurements
                            CREATE TABLE CUSTOMER_MEASUREMENTS ( ID UUID PRIMARY KEY DEFAULT UUID_GENERATE_V4(), CUSTOMER_ID UUID NOT NULL REFERENCES CUSTOMERS(ID), MEASUREMENT_SET_NAME VARCHAR(255) DEFAULT 'Default', MEASUREMENTS JSONB NOT NULL DEFAULT '{}', UNIT MEASUREMENT_UNIT DEFAULT 'cm', MEASURED_BY UUID REFERENCES USERS(ID), MEASUREMENT_DATE DATE DEFAULT CURRENT_DATE, NOTES TEXT, IS_ACTIVE BOOLEAN DEFAULT TRUE, CREATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW(), UPDATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW() );
 
                            -- ============================================================================
                            -- AI & DESIGN TABLES
                            -- ============================================================================
                            -- AI design suggestions
                            CREATE TABLE AI_DESIGN_SUGGESTIONS ( ID UUID PRIMARY KEY DEFAULT UUID_GENERATE_V4(), CUSTOMER_ID UUID REFERENCES CUSTOMERS(ID), PROMPT TEXT NOT NULL, GENERATED_DESIGNS JSONB DEFAULT '[]', SELECTED_DESIGN JSONB, FEEDBACK_RATING INTEGER CHECK (FEEDBACK_RATING >= 1
                            AND FEEDBACK_RATING <= 5), FEEDBACK_NOTES TEXT, AI_MODEL_USED VARCHAR(100), PROCESSING_TIME_MS INTEGER, CREATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW() );
 
                            -- Design collaborations
                            CREATE TABLE DESIGN_COLLABORATIONS ( ID UUID PRIMARY KEY DEFAULT UUID_GENERATE_V4(), CUSTOMER_ID UUID NOT NULL REFERENCES CUSTOMERS(ID), TAILOR_ID UUID NOT NULL REFERENCES TAILORS(ID), ORDER_ID UUID REFERENCES ORDERS(ID), DESIGN_DATA JSONB DEFAULT '{}', COLLABORATION_NOTES TEXT, STATUS VARCHAR(50) DEFAULT 'active', LAST_UPDATED_BY UUID REFERENCES USERS(ID), CREATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW(), UPDATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW() );
 
                            -- ============================================================================
                            -- COMMUNICATION TABLES
                            -- ============================================================================
                            -- Chat rooms for customer-tailor communication
                            CREATE TABLE CHAT_ROOMS ( ID UUID PRIMARY KEY DEFAULT UUID_GENERATE_V4(), CUSTOMER_ID UUID NOT NULL REFERENCES CUSTOMERS(ID), TAILOR_ID UUID NOT NULL REFERENCES TAILORS(ID), ORDER_ID UUID REFERENCES ORDERS(ID), ROOM_NAME VARCHAR(255), LAST_MESSAGE_AT TIMESTAMP WITH TIME ZONE, IS_ACTIVE BOOLEAN DEFAULT TRUE, CREATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW() );
 
                            -- Chat messages
                            CREATE TABLE CHAT_MESSAGES ( ID UUID PRIMARY KEY DEFAULT UUID_GENERATE_V4(), CHAT_ROOM_ID UUID NOT NULL REFERENCES CHAT_ROOMS(ID) ON DELETE CASCADE, SENDER_ID UUID NOT NULL REFERENCES USERS(ID), MESSAGE_TYPE VARCHAR(50) DEFAULT 'text', CONTENT TEXT, ATTACHMENTS JSONB DEFAULT '[]', IS_READ BOOLEAN DEFAULT FALSE, EDITED_AT TIMESTAMP WITH TIME ZONE, CREATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW() );
 
                            -- Notifications
                            CREATE TABLE NOTIFICATIONS ( ID UUID PRIMARY KEY DEFAULT UUID_GENERATE_V4(), USER_ID UUID NOT NULL REFERENCES USERS(ID) ON DELETE CASCADE, TITLE VARCHAR(255) NOT NULL, MESSAGE TEXT NOT NULL, TYPE NOTIFICATION_TYPE DEFAULT 'system', DATA JSONB DEFAULT '{}', IS_READ BOOLEAN DEFAULT FALSE, IS_IMPORTANT BOOLEAN DEFAULT FALSE, EXPIRES_AT TIMESTAMP WITH TIME ZONE, CREATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW() );
 
                            -- ============================================================================
                            -- BUSINESS ANALYTICS TABLES
                            -- ============================================================================
                            -- Order tracking for analytics
                            CREATE TABLE ORDER_STATUS_HISTORY ( ID UUID PRIMARY KEY DEFAULT UUID_GENERATE_V4(), ORDER_ID UUID NOT NULL REFERENCES ORDERS(ID) ON DELETE CASCADE, PREVIOUS_STATUS ORDER_STATUS, NEW_STATUS ORDER_STATUS NOT NULL, CHANGED_BY UUID REFERENCES USERS(ID), NOTES TEXT, CREATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW() );
 
                            -- Payment transactions
                            CREATE TABLE PAYMENT_TRANSACTIONS ( ID UUID PRIMARY KEY DEFAULT UUID_GENERATE_V4(), ORDER_ID UUID NOT NULL REFERENCES ORDERS(ID), TRANSACTION_ID VARCHAR(255) UNIQUE NOT NULL, AMOUNT DECIMAL(10, 2) NOT NULL, CURRENCY VARCHAR(3) DEFAULT 'USD', PAYMENT_METHOD VARCHAR(100), PAYMENT_GATEWAY VARCHAR(100), STATUS PAYMENT_STATUS DEFAULT 'pending', GATEWAY_RESPONSE JSONB DEFAULT '{}', CREATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW(), UPDATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW() );
 
                            -- Admin activity logs
                            CREATE TABLE ADMIN_ACTIVITY_LOGS ( ID UUID PRIMARY KEY DEFAULT UUID_GENERATE_V4(), ADMIN_ID UUID NOT NULL REFERENCES ADMINS(ID), ACTION VARCHAR(255) NOT NULL, ENTITY_TYPE VARCHAR(100), ENTITY_ID UUID, DETAILS JSONB DEFAULT '{}', IP_ADDRESS INET, USER_AGENT TEXT, CREATED_AT TIMESTAMP WITH TIME ZONE DEFAULT NOW() );
 
                            -- ============================================================================
                            -- STORAGE BUCKETS
                            -- ============================================================================
                            -- Create storage buckets for file management
                            INSERT INTO STORAGE.BUCKETS (
                                ID,
                                NAME,
                                PUBLIC
                            ) VALUES (
                                'avatars',
                                'avatars',
                                TRUE
                            ), (
                                'garment-images',
                                'garment-images',
                                TRUE
                            ), (
                                'fabric-samples',
                                'fabric-samples',
                                TRUE
                            ), (
                                'pattern-files',
                                'pattern-files',
                                FALSE
                            ), (
                                'order-documents',
                                'order-documents',
                                FALSE
                            ), (
                                'chat-attachments',
                                'chat-attachments',
                                FALSE
                            );
 
                            -- ============================================================================
                            -- INDEXES FOR PERFORMANCE
                            -- ============================================================================
                            -- User indexes
                            CREATE INDEX IDX_USERS_EMAIL ON USERS(EMAIL);
                            CREATE INDEX IDX_USERS_PHONE ON USERS(PHONE);
                            CREATE INDEX IDX_USERS_ROLE ON USERS(ROLE);
 
                            -- Order indexes
                            CREATE INDEX IDX_ORDERS_CUSTOMER_ID ON ORDERS(CUSTOMER_ID);
                            CREATE INDEX IDX_ORDERS_TAILOR_ID ON ORDERS(TAILOR_ID);
                            CREATE INDEX IDX_ORDERS_STATUS ON ORDERS(STATUS);
                            CREATE INDEX IDX_ORDERS_CREATED_AT ON ORDERS(CREATED_AT);
                            CREATE INDEX IDX_ORDERS_ORDER_NUMBER ON ORDERS(ORDER_NUMBER);
 
                            -- Order items indexes
                            CREATE INDEX IDX_ORDER_ITEMS_ORDER_ID ON ORDER_ITEMS(ORDER_ID);
                            CREATE INDEX IDX_ORDER_ITEMS_GARMENT_TEMPLATE_ID ON ORDER_ITEMS(GARMENT_TEMPLATE_ID);
 
                            -- Notification indexes
                            CREATE INDEX IDX_NOTIFICATIONS_USER_ID ON NOTIFICATIONS(USER_ID);
                            CREATE INDEX IDX_NOTIFICATIONS_IS_READ ON NOTIFICATIONS(IS_READ);
                            CREATE INDEX IDX_NOTIFICATIONS_CREATED_AT ON NOTIFICATIONS(CREATED_AT);
 
                            -- Chat indexes
                            CREATE INDEX IDX_CHAT_ROOMS_CUSTOMER_ID ON CHAT_ROOMS(CUSTOMER_ID);
                            CREATE INDEX IDX_CHAT_ROOMS_TAILOR_ID ON CHAT_ROOMS(TAILOR_ID);
                            CREATE INDEX IDX_CHAT_MESSAGES_CHAT_ROOM_ID ON CHAT_MESSAGES(CHAT_ROOM_ID);
                            CREATE INDEX IDX_CHAT_MESSAGES_SENDER_ID ON CHAT_MESSAGES(SENDER_ID);
 
                            -- Fabric and template indexes
                            CREATE INDEX IDX_FABRICS_TYPE ON FABRICS(TYPE);
                            CREATE INDEX IDX_FABRICS_IS_AVAILABLE ON FABRICS(IS_AVAILABLE);
                            CREATE INDEX IDX_GARMENT_TEMPLATES_CATEGORY ON GARMENT_TEMPLATES(CATEGORY);
                            CREATE INDEX IDX_GARMENT_TEMPLATES_IS_ACTIVE ON GARMENT_TEMPLATES(IS_ACTIVE);
 
                            -- ============================================================================
                            -- FUNCTIONS FOR AUTOMATIC UPDATES
                            -- ============================================================================
                            -- Function to automatically update updated_at timestamp
                            CREATE OR REPLACE FUNCTION UPDATE_UPDATED_AT_COLUMN() RETURNS TRIGGER AS
                                $$
                                BEGIN
                                    NEW.UPDATED_AT = NOW();
                                    RETURN NEW;
                                END;

                                $$ LANGUAGE 'plpgsql';
 
                                -- Add triggers for automatic timestamp updates
                                CREATE TRIGGER UPDATE_USERS_UPDATED_AT BEFORE
                                UPDATE ON USERS FOR EACH ROW EXECUTE FUNCTION UPDATE_UPDATED_AT_COLUMN(
                                );
                                CREATE TRIGGER UPDATE_CUSTOMERS_UPDATED_AT BEFORE
                                UPDATE ON CUSTOMERS FOR EACH ROW EXECUTE FUNCTION UPDATE_UPDATED_AT_COLUMN(
                                );
                                CREATE TRIGGER UPDATE_TAILORS_UPDATED_AT BEFORE
                                UPDATE ON TAILORS FOR EACH ROW EXECUTE FUNCTION UPDATE_UPDATED_AT_COLUMN(
                                );
                                CREATE TRIGGER UPDATE_ADMINS_UPDATED_AT BEFORE
                                UPDATE ON ADMINS FOR EACH ROW EXECUTE FUNCTION UPDATE_UPDATED_AT_COLUMN(
                                );
                                CREATE TRIGGER UPDATE_ORDERS_UPDATED_AT BEFORE
                                UPDATE ON ORDERS FOR EACH ROW EXECUTE FUNCTION UPDATE_UPDATED_AT_COLUMN(
                                );
                                CREATE TRIGGER UPDATE_ORDER_ITEMS_UPDATED_AT BEFORE
                                UPDATE ON ORDER_ITEMS FOR EACH ROW EXECUTE FUNCTION UPDATE_UPDATED_AT_COLUMN(
                                );
                                CREATE TRIGGER UPDATE_FABRICS_UPDATED_AT BEFORE
                                UPDATE ON FABRICS FOR EACH ROW EXECUTE FUNCTION UPDATE_UPDATED_AT_COLUMN(
                                );
                                CREATE TRIGGER UPDATE_GARMENT_TEMPLATES_UPDATED_AT BEFORE
                                UPDATE ON GARMENT_TEMPLATES FOR EACH ROW EXECUTE FUNCTION UPDATE_UPDATED_AT_COLUMN(
                                );
 
                                -- ============================================================================
                                -- SAMPLE DATA FOR DEVELOPMENT
                                -- ============================================================================
                                -- Insert sample countries
                                INSERT INTO COUNTRIES (
                                    NAME,
                                    CODE,
                                    PHONE_CODE,
                                    CURRENCY
                                ) VALUES (
                                    'United States',
                                    'US',
                                    '+1',
                                    'USD'
                                ), (
                                    'India',
                                    'IN',
                                    '+91',
                                    'INR'
                                ), (
                                    'United Kingdom',
                                    'GB',
                                    '+44',
                                    'GBP'
                                ), (
                                    'Canada',
                                    'CA',
                                    '+1',
                                    'CAD'
                                ), (
                                    'Australia',
                                    'AU',
                                    '+61',
                                    'AUD'
                                );
 
                                -- Insert sample fabrics
                                INSERT INTO FABRICS (
                                    NAME,
                                    TYPE,
                                    BRAND,
                                    COLOR,
                                    PRICE_PER_METER,
                                    DESCRIPTION
                                ) VALUES (
                                    'Premium Cotton Shirting',
                                    'cotton',
                                    'TextileCorp',
                                    'White',
                                    25.00,
                                    'High-quality cotton perfect for formal shirts'
                                ), (
                                    'Silk Charmeuse',
                                    'silk',
                                    'LuxuryFabrics',
                                    'Navy Blue',
                                    85.00,
                                    'Luxurious silk with beautiful drape'
                                ), (
                                    'Wool Suiting',
                                    'wool',
                                    'WoolMasters',
                                    'Charcoal Grey',
                                    120.00,
                                    'Premium wool for tailored suits'
                                ), (
                                    'Linen Blend',
                                    'blend',
                                    'NaturalWeaves',
                                    'Light Blue',
                                    35.00,
                                    'Breathable linen blend for casual wear'
                                );
 
                                -- Insert sample garment templates
                                INSERT INTO GARMENT_TEMPLATES (
                                    NAME,
                                    CATEGORY,
                                    DESCRIPTION,
                                    BASE_PRICE
                                ) VALUES (
                                    'Classic Business Shirt',
                                    'shirt',
                                    'Traditional formal shirt perfect for business settings',
                                    75.00
                                ), (
                                    'Modern Casual Dress',
                                    'dress',
                                    'Contemporary dress design with clean lines',
                                    120.00
                                ), (
                                    'Tailored Suit Jacket',
                                    'jacket',
                                    'Custom-fitted suit jacket',
                                    200.00
                                ), (
                                    'Traditional Kurta',
                                    'traditional_wear',
                                    'Classic Indian kurta design',
                                    60.00
                                );
 
                                -- ============================================================================
                                -- GRANT PERMISSIONS
                                -- ============================================================================
                                -- Grant usage on schema
                                GRANT USAGE ON SCHEMA PUBLIC TO POSTGRES, ANON, AUTHENTICATED, SERVICE_ROLE;
 
                                -- Grant permissions on tables to authenticated users
                                GRANT ALL ON ALL TABLES IN SCHEMA PUBLIC TO POSTGRES, SERVICE_ROLE;
                                GRANT
                                SELECT,
                                    INSERT,
                                    UPDATE,
                                    DELETE
                                    ON ALL TABLES IN SCHEMA PUBLIC TO AUTHENTICATED;
                                GRANT
                                SELECT
                                    ON ALL TABLES IN SCHEMA PUBLIC TO ANON;
 
                                -- Grant permissions on sequences
                                GRANT ALL ON ALL SEQUENCES IN SCHEMA PUBLIC TO POSTGRES, SERVICE_ROLE;
                                GRANT USAGE ON ALL SEQUENCES IN SCHEMA PUBLIC TO AUTHENTICATED;
 
                                -- ============================================================================
                                -- COMPLETION MESSAGE
                                -- ============================================================================
                                -- Log completion
                                DO $$
                                BEGIN
                                    RAISE NOTICE 'TailorApp database schema created successfully!';
                                    RAISE NOTICE 'Tables created: users, customers, tailors, admins, orders, order_items, fabrics, garment_templates, and more';
                                    RAISE NOTICE 'Indexes, triggers, and sample data have been added';
                                    RAISE NOTICE 'Storage buckets configured for file management';
                                    RAISE NOTICE 'Ready for application integration!';
                                END $$;