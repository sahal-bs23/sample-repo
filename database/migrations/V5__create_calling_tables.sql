-- V5__create_calling_tables.sql
-- Tables for audio/video calling system

-- Create calls table
CREATE TABLE calls (
    id BIGSERIAL PRIMARY KEY,
    call_type call_type NOT NULL,
    status call_status DEFAULT 'INITIATED',
    
    -- Call participants
    caller_id BIGINT NOT NULL REFERENCES users(id),
    conversation_id BIGINT REFERENCES conversations(id) ON DELETE SET NULL,
    
    -- Call details
    title VARCHAR(255), -- For group calls
    description TEXT,
    
    -- Timing
    initiated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    started_at TIMESTAMP,
    ended_at TIMESTAMP,
    duration_seconds INTEGER DEFAULT 0,
    
    -- Technical details
    room_id VARCHAR(255) UNIQUE, -- WebRTC room identifier
    server_url VARCHAR(500), -- Signaling server URL
    
    -- Call settings
    is_recording_enabled BOOLEAN DEFAULT false,
    recording_url VARCHAR(500),
    max_participants INTEGER DEFAULT 10,
    current_participant_count INTEGER DEFAULT 0,
    
    -- Quality metrics
    average_quality_score DECIMAL(3,2), -- 1.00 to 5.00
    connection_issues_count INTEGER DEFAULT 0,
    
    -- Metadata
    call_metadata JSONB, -- Additional call data
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create call_participants table
CREATE TABLE call_participants (
    id BIGSERIAL PRIMARY KEY,
    call_id BIGINT NOT NULL REFERENCES calls(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Participation details
    status VARCHAR(20) DEFAULT 'INVITED', -- 'INVITED', 'RINGING', 'JOINED', 'LEFT', 'REJECTED', 'MISSED'
    role VARCHAR(20) DEFAULT 'PARTICIPANT', -- 'HOST', 'MODERATOR', 'PARTICIPANT'
    
    -- Join/leave tracking
    invited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    joined_at TIMESTAMP,
    left_at TIMESTAMP,
    duration_seconds INTEGER DEFAULT 0,
    
    -- Call controls
    is_audio_muted BOOLEAN DEFAULT false,
    is_video_disabled BOOLEAN DEFAULT false,
    is_screen_sharing BOOLEAN DEFAULT false,
    
    -- Connection details
    peer_id VARCHAR(255), -- WebRTC peer identifier
    connection_quality VARCHAR(20) DEFAULT 'UNKNOWN', -- 'EXCELLENT', 'GOOD', 'FAIR', 'POOR', 'UNKNOWN'
    
    -- Technical metrics
    audio_bitrate INTEGER,
    video_bitrate INTEGER,
    packet_loss_percentage DECIMAL(5,2),
    latency_ms INTEGER,
    
    -- Device information
    device_type VARCHAR(50), -- 'DESKTOP', 'MOBILE', 'TABLET'
    browser_info VARCHAR(255),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(call_id, user_id)
);

-- Create call_invitations table
CREATE TABLE call_invitations (
    id BIGSERIAL PRIMARY KEY,
    call_id BIGINT NOT NULL REFERENCES calls(id) ON DELETE CASCADE,
    inviter_id BIGINT NOT NULL REFERENCES users(id),
    invitee_id BIGINT NOT NULL REFERENCES users(id),
    
    -- Invitation details
    invitation_type VARCHAR(20) DEFAULT 'DIRECT', -- 'DIRECT', 'GROUP'
    message TEXT,
    
    -- Status tracking
    status VARCHAR(20) DEFAULT 'PENDING', -- 'PENDING', 'ACCEPTED', 'DECLINED', 'EXPIRED'
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP,
    expires_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL '2 minutes'),
    
    -- Notification details
    notification_sent BOOLEAN DEFAULT false,
    push_notification_id VARCHAR(255),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(call_id, invitee_id)
);

-- Create call_recordings table
CREATE TABLE call_recordings (
    id BIGSERIAL PRIMARY KEY,
    call_id BIGINT NOT NULL REFERENCES calls(id) ON DELETE CASCADE,
    
    -- Recording details
    recording_url VARCHAR(500) NOT NULL,
    file_size BIGINT,
    duration_seconds INTEGER,
    format VARCHAR(20) DEFAULT 'MP4',
    
    -- Processing status
    status VARCHAR(20) DEFAULT 'PROCESSING', -- 'PROCESSING', 'READY', 'FAILED'
    processing_started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processing_completed_at TIMESTAMP,
    
    -- Access control
    is_public BOOLEAN DEFAULT false,
    password_protected BOOLEAN DEFAULT false,
    access_password VARCHAR(255),
    expires_at TIMESTAMP,
    
    -- Metadata
    thumbnail_url VARCHAR(500),
    transcript_url VARCHAR(500),
    
    created_by BIGINT REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create call_messages table (chat during calls)
CREATE TABLE call_messages (
    id BIGSERIAL PRIMARY KEY,
    call_id BIGINT NOT NULL REFERENCES calls(id) ON DELETE CASCADE,
    sender_id BIGINT NOT NULL REFERENCES users(id),
    
    -- Message content
    message TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'TEXT', -- 'TEXT', 'SYSTEM'
    
    -- Timing
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- System message details
    system_action VARCHAR(50), -- 'USER_JOINED', 'USER_LEFT', 'RECORDING_STARTED', etc.
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create call_quality_reports table
CREATE TABLE call_quality_reports (
    id BIGSERIAL PRIMARY KEY,
    call_id BIGINT NOT NULL REFERENCES calls(id) ON DELETE CASCADE,
    participant_id BIGINT NOT NULL REFERENCES call_participants(id) ON DELETE CASCADE,
    
    -- Quality metrics
    overall_rating INTEGER CHECK (overall_rating >= 1 AND overall_rating <= 5),
    audio_quality INTEGER CHECK (audio_quality >= 1 AND audio_quality <= 5),
    video_quality INTEGER CHECK (video_quality >= 1 AND video_quality <= 5),
    connection_stability INTEGER CHECK (connection_stability >= 1 AND connection_stability <= 5),
    
    -- Issues reported
    audio_issues JSONB, -- Array of audio issues
    video_issues JSONB, -- Array of video issues
    connection_issues JSONB, -- Array of connection issues
    
    -- Feedback
    comments TEXT,
    would_use_again BOOLEAN,
    
    -- Technical data
    browser_info VARCHAR(255),
    device_info VARCHAR(255),
    network_type VARCHAR(50),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create call_analytics table (for aggregated call statistics)
CREATE TABLE call_analytics (
    id BIGSERIAL PRIMARY KEY,
    date DATE NOT NULL,
    
    -- Call statistics
    total_calls INTEGER DEFAULT 0,
    successful_calls INTEGER DEFAULT 0,
    failed_calls INTEGER DEFAULT 0,
    
    -- Duration statistics
    total_duration_minutes INTEGER DEFAULT 0,
    average_duration_minutes DECIMAL(10,2) DEFAULT 0,
    
    -- Participant statistics
    total_participants INTEGER DEFAULT 0,
    unique_participants INTEGER DEFAULT 0,
    
    -- Quality statistics
    average_quality_score DECIMAL(3,2),
    quality_issues_count INTEGER DEFAULT 0,
    
    -- Call type breakdown
    audio_calls_count INTEGER DEFAULT 0,
    video_calls_count INTEGER DEFAULT 0,
    group_calls_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(date)
);

-- Create indexes for better performance
CREATE INDEX idx_calls_caller_id ON calls(caller_id);
CREATE INDEX idx_calls_conversation_id ON calls(conversation_id);
CREATE INDEX idx_calls_call_type ON calls(call_type);
CREATE INDEX idx_calls_status ON calls(status);
CREATE INDEX idx_calls_initiated_at ON calls(initiated_at);
CREATE INDEX idx_calls_room_id ON calls(room_id);

CREATE INDEX idx_call_participants_call_id ON call_participants(call_id);
CREATE INDEX idx_call_participants_user_id ON call_participants(user_id);
CREATE INDEX idx_call_participants_status ON call_participants(status);
CREATE INDEX idx_call_participants_joined_at ON call_participants(joined_at);

CREATE INDEX idx_call_invitations_call_id ON call_invitations(call_id);
CREATE INDEX idx_call_invitations_inviter_id ON call_invitations(inviter_id);
CREATE INDEX idx_call_invitations_invitee_id ON call_invitations(invitee_id);
CREATE INDEX idx_call_invitations_status ON call_invitations(status);
CREATE INDEX idx_call_invitations_expires_at ON call_invitations(expires_at);

CREATE INDEX idx_call_recordings_call_id ON call_recordings(call_id);
CREATE INDEX idx_call_recordings_status ON call_recordings(status);
CREATE INDEX idx_call_recordings_created_by ON call_recordings(created_by);

CREATE INDEX idx_call_messages_call_id ON call_messages(call_id);
CREATE INDEX idx_call_messages_sender_id ON call_messages(sender_id);
CREATE INDEX idx_call_messages_sent_at ON call_messages(sent_at);

CREATE INDEX idx_call_quality_reports_call_id ON call_quality_reports(call_id);
CREATE INDEX idx_call_quality_reports_participant_id ON call_quality_reports(participant_id);
CREATE INDEX idx_call_quality_reports_overall_rating ON call_quality_reports(overall_rating);

CREATE INDEX idx_call_analytics_date ON call_analytics(date);

-- Create triggers for updating updated_at timestamps
CREATE TRIGGER update_calls_updated_at BEFORE UPDATE ON calls
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_call_participants_updated_at BEFORE UPDATE ON call_participants
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_call_invitations_updated_at BEFORE UPDATE ON call_invitations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_call_recordings_updated_at BEFORE UPDATE ON call_recordings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_call_analytics_updated_at BEFORE UPDATE ON call_analytics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function to update call participant count
CREATE OR REPLACE FUNCTION update_call_participant_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.status = 'JOINED' THEN
            UPDATE calls SET current_participant_count = current_participant_count + 1 WHERE id = NEW.call_id;
        END IF;
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.status != 'JOINED' AND NEW.status = 'JOINED' THEN
            UPDATE calls SET current_participant_count = current_participant_count + 1 WHERE id = NEW.call_id;
        ELSIF OLD.status = 'JOINED' AND NEW.status != 'JOINED' THEN
            UPDATE calls SET current_participant_count = current_participant_count - 1 WHERE id = NEW.call_id;
        END IF;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        IF OLD.status = 'JOINED' THEN
            UPDATE calls SET current_participant_count = current_participant_count - 1 WHERE id = OLD.call_id;
        END IF;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for participant count updates
CREATE TRIGGER trigger_update_call_participant_count
    AFTER INSERT OR UPDATE OR DELETE ON call_participants
    FOR EACH ROW EXECUTE FUNCTION update_call_participant_count();

-- Create function to calculate call duration
CREATE OR REPLACE FUNCTION calculate_call_duration()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.left_at IS NOT NULL AND NEW.joined_at IS NOT NULL THEN
        NEW.duration_seconds = EXTRACT(EPOCH FROM (NEW.left_at - NEW.joined_at))::INTEGER;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for duration calculation
CREATE TRIGGER trigger_calculate_call_duration
    BEFORE UPDATE ON call_participants
    FOR EACH ROW EXECUTE FUNCTION calculate_call_duration();

-- Create function to update call status based on participants
CREATE OR REPLACE FUNCTION update_call_status()
RETURNS TRIGGER AS $$
DECLARE
    participant_count INTEGER;
    active_participants INTEGER;
BEGIN
    -- Get participant counts
    SELECT COUNT(*), COUNT(CASE WHEN status = 'JOINED' THEN 1 END)
    INTO participant_count, active_participants
    FROM call_participants
    WHERE call_id = COALESCE(NEW.call_id, OLD.call_id);
    
    -- Update call status based on participant activity
    IF active_participants > 0 THEN
        UPDATE calls SET status = 'CONNECTED' WHERE id = COALESCE(NEW.call_id, OLD.call_id) AND status != 'ENDED';
    ELSIF participant_count > 0 AND active_participants = 0 THEN
        UPDATE calls 
        SET status = 'ENDED', 
            ended_at = CURRENT_TIMESTAMP,
            duration_seconds = EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - COALESCE(started_at, initiated_at)))::INTEGER
        WHERE id = COALESCE(NEW.call_id, OLD.call_id) AND status != 'ENDED';
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Create trigger for call status updates
CREATE TRIGGER trigger_update_call_status
    AFTER INSERT OR UPDATE OR DELETE ON call_participants
    FOR EACH ROW EXECUTE FUNCTION update_call_status();

-- Create function to clean up expired call invitations
CREATE OR REPLACE FUNCTION cleanup_expired_call_invitations()
RETURNS void AS $$
BEGIN
    UPDATE call_invitations 
    SET status = 'EXPIRED' 
    WHERE status = 'PENDING' AND expires_at < CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

-- Create function to generate unique room ID
CREATE OR REPLACE FUNCTION generate_room_id()
RETURNS TEXT AS $$
DECLARE
    room_id TEXT;
BEGIN
    LOOP
        room_id := 'room_' || encode(gen_random_bytes(16), 'hex');
        EXIT WHEN NOT EXISTS (SELECT 1 FROM calls WHERE room_id = room_id);
    END LOOP;
    RETURN room_id;
END;
$$ LANGUAGE plpgsql;

