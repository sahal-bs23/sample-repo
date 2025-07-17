-- V2__create_events_tables.sql
-- Tables for event management system

-- Create event_categories table
CREATE TABLE event_categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(7) DEFAULT '#3B82F6', -- Hex color code
    icon VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create events table
CREATE TABLE events (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    short_description VARCHAR(500),
    category_id BIGINT REFERENCES event_categories(id),
    organizer_id BIGINT NOT NULL REFERENCES users(id),
    event_type VARCHAR(20) DEFAULT 'PHYSICAL', -- 'PHYSICAL', 'VIRTUAL', 'HYBRID'
    status event_status DEFAULT 'DRAFT',
    
    -- Date and time
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    registration_start_date TIMESTAMP,
    registration_end_date TIMESTAMP,
    
    -- Location details
    venue_name VARCHAR(255),
    venue_address TEXT,
    venue_city VARCHAR(100),
    venue_country VARCHAR(100),
    virtual_meeting_url VARCHAR(500),
    virtual_meeting_id VARCHAR(100),
    virtual_meeting_password VARCHAR(100),
    
    -- Capacity and registration
    max_participants INTEGER,
    current_participants INTEGER DEFAULT 0,
    is_registration_required BOOLEAN DEFAULT true,
    is_approval_required BOOLEAN DEFAULT false,
    
    -- Payment details
    is_paid_event BOOLEAN DEFAULT false,
    ticket_price DECIMAL(10,2) DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'USD',
    
    -- Media and content
    banner_image_url VARCHAR(500),
    gallery_images JSONB, -- Array of image URLs
    event_agenda JSONB, -- Structured agenda data
    
    -- Additional settings
    is_featured BOOLEAN DEFAULT false,
    is_public BOOLEAN DEFAULT true,
    allow_guest_registration BOOLEAN DEFAULT false,
    send_reminders BOOLEAN DEFAULT true,
    
    -- SEO and sharing
    slug VARCHAR(255) UNIQUE,
    meta_title VARCHAR(255),
    meta_description VARCHAR(500),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create event_registrations table
CREATE TABLE event_registrations (
    id BIGSERIAL PRIMARY KEY,
    event_id BIGINT NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    
    -- Guest registration details (if user_id is null)
    guest_name VARCHAR(255),
    guest_email VARCHAR(255),
    guest_phone VARCHAR(20),
    
    registration_status VARCHAR(20) DEFAULT 'PENDING', -- 'PENDING', 'CONFIRMED', 'CANCELLED', 'WAITLISTED'
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    confirmation_date TIMESTAMP,
    cancellation_date TIMESTAMP,
    cancellation_reason TEXT,
    
    -- Payment details
    payment_status payment_status DEFAULT 'PENDING',
    payment_amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    payment_transaction_id VARCHAR(255),
    payment_date TIMESTAMP,
    
    -- Additional data
    registration_data JSONB, -- Custom form data
    attendance_status VARCHAR(20) DEFAULT 'REGISTERED', -- 'REGISTERED', 'ATTENDED', 'NO_SHOW'
    check_in_time TIMESTAMP,
    check_out_time TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(event_id, user_id),
    UNIQUE(event_id, guest_email)
);

-- Create event_speakers table
CREATE TABLE event_speakers (
    id BIGSERIAL PRIMARY KEY,
    event_id BIGINT NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    
    -- Speaker details (if not a registered user)
    name VARCHAR(255) NOT NULL,
    title VARCHAR(255),
    company VARCHAR(255),
    bio TEXT,
    profile_image_url VARCHAR(500),
    
    -- Social links
    linkedin_url VARCHAR(500),
    twitter_url VARCHAR(500),
    website_url VARCHAR(500),
    
    -- Speaking details
    topic VARCHAR(255),
    session_time TIMESTAMP,
    session_duration INTEGER, -- in minutes
    is_keynote BOOLEAN DEFAULT false,
    display_order INTEGER DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create event_sponsors table
CREATE TABLE event_sponsors (
    id BIGSERIAL PRIMARY KEY,
    event_id BIGINT NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    logo_url VARCHAR(500),
    website_url VARCHAR(500),
    description TEXT,
    sponsor_type VARCHAR(50) DEFAULT 'GENERAL', -- 'TITLE', 'PLATINUM', 'GOLD', 'SILVER', 'BRONZE', 'GENERAL'
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create event_feedback table
CREATE TABLE event_feedback (
    id BIGSERIAL PRIMARY KEY,
    event_id BIGINT NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    registration_id BIGINT REFERENCES event_registrations(id) ON DELETE CASCADE,
    
    -- Ratings (1-5 scale)
    overall_rating INTEGER CHECK (overall_rating >= 1 AND overall_rating <= 5),
    content_rating INTEGER CHECK (content_rating >= 1 AND content_rating <= 5),
    organization_rating INTEGER CHECK (organization_rating >= 1 AND organization_rating <= 5),
    venue_rating INTEGER CHECK (venue_rating >= 1 AND venue_rating <= 5),
    
    -- Feedback text
    comments TEXT,
    suggestions TEXT,
    
    -- Recommendation
    would_recommend BOOLEAN,
    would_attend_again BOOLEAN,
    
    -- Additional data
    feedback_data JSONB, -- Custom feedback form data
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(event_id, user_id)
);

-- Create event_notifications table
CREATE TABLE event_notifications (
    id BIGSERIAL PRIMARY KEY,
    event_id BIGINT NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL, -- 'REGISTRATION_OPEN', 'REMINDER', 'UPDATE', 'CANCELLATION'
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    scheduled_at TIMESTAMP NOT NULL,
    sent_at TIMESTAMP,
    recipient_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_by BIGINT REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_events_organizer_id ON events(organizer_id);
CREATE INDEX idx_events_category_id ON events(category_id);
CREATE INDEX idx_events_status ON events(status);
CREATE INDEX idx_events_start_date ON events(start_date);
CREATE INDEX idx_events_end_date ON events(end_date);
CREATE INDEX idx_events_is_public ON events(is_public);
CREATE INDEX idx_events_is_featured ON events(is_featured);
CREATE INDEX idx_events_slug ON events(slug);
CREATE INDEX idx_events_created_at ON events(created_at);

CREATE INDEX idx_event_registrations_event_id ON event_registrations(event_id);
CREATE INDEX idx_event_registrations_user_id ON event_registrations(user_id);
CREATE INDEX idx_event_registrations_status ON event_registrations(registration_status);
CREATE INDEX idx_event_registrations_payment_status ON event_registrations(payment_status);
CREATE INDEX idx_event_registrations_guest_email ON event_registrations(guest_email);
CREATE INDEX idx_event_registrations_created_at ON event_registrations(created_at);

CREATE INDEX idx_event_speakers_event_id ON event_speakers(event_id);
CREATE INDEX idx_event_speakers_user_id ON event_speakers(user_id);
CREATE INDEX idx_event_speakers_session_time ON event_speakers(session_time);

CREATE INDEX idx_event_sponsors_event_id ON event_sponsors(event_id);
CREATE INDEX idx_event_sponsors_sponsor_type ON event_sponsors(sponsor_type);

CREATE INDEX idx_event_feedback_event_id ON event_feedback(event_id);
CREATE INDEX idx_event_feedback_user_id ON event_feedback(user_id);
CREATE INDEX idx_event_feedback_overall_rating ON event_feedback(overall_rating);

CREATE INDEX idx_event_notifications_event_id ON event_notifications(event_id);
CREATE INDEX idx_event_notifications_scheduled_at ON event_notifications(scheduled_at);
CREATE INDEX idx_event_notifications_sent_at ON event_notifications(sent_at);

-- Create full-text search indexes
CREATE INDEX idx_events_search ON events USING gin(to_tsvector('english', title || ' ' || COALESCE(description, '')));
CREATE INDEX idx_event_categories_search ON event_categories USING gin(to_tsvector('english', name || ' ' || COALESCE(description, '')));

-- Create triggers for updating updated_at timestamps
CREATE TRIGGER update_event_categories_updated_at BEFORE UPDATE ON event_categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_event_registrations_updated_at BEFORE UPDATE ON event_registrations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_event_speakers_updated_at BEFORE UPDATE ON event_speakers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_event_sponsors_updated_at BEFORE UPDATE ON event_sponsors
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_event_feedback_updated_at BEFORE UPDATE ON event_feedback
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_event_notifications_updated_at BEFORE UPDATE ON event_notifications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function to update current_participants count
CREATE OR REPLACE FUNCTION update_event_participants_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.registration_status = 'CONFIRMED' THEN
            UPDATE events SET current_participants = current_participants + 1 WHERE id = NEW.event_id;
        END IF;
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.registration_status != 'CONFIRMED' AND NEW.registration_status = 'CONFIRMED' THEN
            UPDATE events SET current_participants = current_participants + 1 WHERE id = NEW.event_id;
        ELSIF OLD.registration_status = 'CONFIRMED' AND NEW.registration_status != 'CONFIRMED' THEN
            UPDATE events SET current_participants = current_participants - 1 WHERE id = NEW.event_id;
        END IF;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        IF OLD.registration_status = 'CONFIRMED' THEN
            UPDATE events SET current_participants = current_participants - 1 WHERE id = OLD.event_id;
        END IF;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for participant count updates
CREATE TRIGGER trigger_update_event_participants_count
    AFTER INSERT OR UPDATE OR DELETE ON event_registrations
    FOR EACH ROW EXECUTE FUNCTION update_event_participants_count();

