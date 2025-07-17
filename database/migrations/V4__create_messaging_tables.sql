-- V4__create_messaging_tables.sql
-- Tables for real-time messaging system (1-to-1 and group chat)

-- Create conversations table (both 1-to-1 and group conversations)
CREATE TABLE conversations (
    id BIGSERIAL PRIMARY KEY,
    conversation_type VARCHAR(20) NOT NULL, -- 'DIRECT', 'GROUP'
    
    -- Group conversation details
    group_id BIGINT REFERENCES groups(id) ON DELETE CASCADE,
    
    -- Conversation metadata
    title VARCHAR(255), -- For group conversations or custom direct conversation names
    description TEXT,
    avatar_url VARCHAR(500),
    
    -- Settings
    is_active BOOLEAN DEFAULT true,
    is_archived BOOLEAN DEFAULT false,
    
    -- Activity tracking
    last_message_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    message_count INTEGER DEFAULT 0,
    
    -- Permissions
    allow_file_sharing BOOLEAN DEFAULT true,
    allow_voice_messages BOOLEAN DEFAULT true,
    
    created_by BIGINT REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create conversation_participants table
CREATE TABLE conversation_participants (
    id BIGSERIAL PRIMARY KEY,
    conversation_id BIGINT NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Participation details
    role VARCHAR(20) DEFAULT 'MEMBER', -- 'ADMIN', 'MEMBER'
    status VARCHAR(20) DEFAULT 'ACTIVE', -- 'ACTIVE', 'LEFT', 'REMOVED'
    
    -- Join/leave tracking
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP,
    
    -- Message tracking
    last_read_message_id BIGINT,
    last_seen_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    unread_count INTEGER DEFAULT 0,
    
    -- Notification settings
    is_muted BOOLEAN DEFAULT false,
    muted_until TIMESTAMP,
    
    -- Permissions
    can_send_messages BOOLEAN DEFAULT true,
    can_add_participants BOOLEAN DEFAULT false,
    can_remove_participants BOOLEAN DEFAULT false,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(conversation_id, user_id)
);

-- Create messages table
CREATE TABLE messages (
    id BIGSERIAL PRIMARY KEY,
    conversation_id BIGINT NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    
    -- Message content
    message_type message_type DEFAULT 'TEXT',
    content TEXT,
    
    -- File attachments
    file_url VARCHAR(500),
    file_name VARCHAR(255),
    file_size BIGINT,
    file_type VARCHAR(100),
    thumbnail_url VARCHAR(500),
    
    -- Message metadata
    is_edited BOOLEAN DEFAULT false,
    edited_at TIMESTAMP,
    is_deleted BOOLEAN DEFAULT false,
    deleted_at TIMESTAMP,
    deleted_by BIGINT REFERENCES users(id),
    
    -- Reply functionality
    reply_to_message_id BIGINT REFERENCES messages(id),
    
    -- Message reactions and interactions
    reaction_count INTEGER DEFAULT 0,
    
    -- System messages
    is_system_message BOOLEAN DEFAULT false,
    system_message_type VARCHAR(50), -- 'USER_JOINED', 'USER_LEFT', 'CONVERSATION_CREATED', etc.
    system_message_data JSONB,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create message_reactions table
CREATE TABLE message_reactions (
    id BIGSERIAL PRIMARY KEY,
    message_id BIGINT NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Reaction details
    emoji VARCHAR(10) NOT NULL, -- Unicode emoji
    reaction_type VARCHAR(50) DEFAULT 'EMOJI', -- 'EMOJI', 'CUSTOM'
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(message_id, user_id, emoji)
);

-- Create message_read_receipts table
CREATE TABLE message_read_receipts (
    id BIGSERIAL PRIMARY KEY,
    message_id BIGINT NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    conversation_id BIGINT NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    
    read_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(message_id, user_id)
);

-- Create message_mentions table
CREATE TABLE message_mentions (
    id BIGSERIAL PRIMARY KEY,
    message_id BIGINT NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    mentioned_user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Mention details
    mention_type VARCHAR(20) DEFAULT 'USER', -- 'USER', 'ALL', 'HERE'
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(message_id, mentioned_user_id)
);

-- Create typing_indicators table (for real-time typing status)
CREATE TABLE typing_indicators (
    id BIGSERIAL PRIMARY KEY,
    conversation_id BIGINT NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    started_typing_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL '10 seconds'),
    
    UNIQUE(conversation_id, user_id)
);

-- Create message_drafts table (for saving unsent messages)
CREATE TABLE message_drafts (
    id BIGSERIAL PRIMARY KEY,
    conversation_id BIGINT NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    draft_content TEXT,
    reply_to_message_id BIGINT REFERENCES messages(id),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(conversation_id, user_id)
);

-- Create conversation_settings table (for user-specific conversation settings)
CREATE TABLE conversation_settings (
    id BIGSERIAL PRIMARY KEY,
    conversation_id BIGINT NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Display settings
    custom_name VARCHAR(255),
    custom_avatar_url VARCHAR(500),
    
    -- Notification settings
    notification_sound VARCHAR(100),
    show_previews BOOLEAN DEFAULT true,
    
    -- Privacy settings
    show_read_receipts BOOLEAN DEFAULT true,
    show_typing_indicator BOOLEAN DEFAULT true,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(conversation_id, user_id)
);

-- Create indexes for better performance
CREATE INDEX idx_conversations_conversation_type ON conversations(conversation_type);
CREATE INDEX idx_conversations_group_id ON conversations(group_id);
CREATE INDEX idx_conversations_is_active ON conversations(is_active);
CREATE INDEX idx_conversations_last_message_at ON conversations(last_message_at);
CREATE INDEX idx_conversations_created_by ON conversations(created_by);
CREATE INDEX idx_conversations_created_at ON conversations(created_at);

CREATE INDEX idx_conversation_participants_conversation_id ON conversation_participants(conversation_id);
CREATE INDEX idx_conversation_participants_user_id ON conversation_participants(user_id);
CREATE INDEX idx_conversation_participants_status ON conversation_participants(status);
CREATE INDEX idx_conversation_participants_last_seen_at ON conversation_participants(last_seen_at);

CREATE INDEX idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_message_type ON messages(message_type);
CREATE INDEX idx_messages_reply_to_message_id ON messages(reply_to_message_id);
CREATE INDEX idx_messages_is_deleted ON messages(is_deleted);
CREATE INDEX idx_messages_created_at ON messages(created_at);

CREATE INDEX idx_message_reactions_message_id ON message_reactions(message_id);
CREATE INDEX idx_message_reactions_user_id ON message_reactions(user_id);
CREATE INDEX idx_message_reactions_emoji ON message_reactions(emoji);

CREATE INDEX idx_message_read_receipts_message_id ON message_read_receipts(message_id);
CREATE INDEX idx_message_read_receipts_user_id ON message_read_receipts(user_id);
CREATE INDEX idx_message_read_receipts_conversation_id ON message_read_receipts(conversation_id);

CREATE INDEX idx_message_mentions_message_id ON message_mentions(message_id);
CREATE INDEX idx_message_mentions_mentioned_user_id ON message_mentions(mentioned_user_id);
CREATE INDEX idx_message_mentions_is_read ON message_mentions(is_read);

CREATE INDEX idx_typing_indicators_conversation_id ON typing_indicators(conversation_id);
CREATE INDEX idx_typing_indicators_user_id ON typing_indicators(user_id);
CREATE INDEX idx_typing_indicators_expires_at ON typing_indicators(expires_at);

CREATE INDEX idx_message_drafts_conversation_id ON message_drafts(conversation_id);
CREATE INDEX idx_message_drafts_user_id ON message_drafts(user_id);

CREATE INDEX idx_conversation_settings_conversation_id ON conversation_settings(conversation_id);
CREATE INDEX idx_conversation_settings_user_id ON conversation_settings(user_id);

-- Create full-text search index for messages
CREATE INDEX idx_messages_search ON messages USING gin(to_tsvector('english', COALESCE(content, '')));

-- Create triggers for updating updated_at timestamps
CREATE TRIGGER update_conversations_updated_at BEFORE UPDATE ON conversations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_conversation_participants_updated_at BEFORE UPDATE ON conversation_participants
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_messages_updated_at BEFORE UPDATE ON messages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_message_drafts_updated_at BEFORE UPDATE ON message_drafts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_conversation_settings_updated_at BEFORE UPDATE ON conversation_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function to update conversation last message time and count
CREATE OR REPLACE FUNCTION update_conversation_on_message()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE conversations 
        SET last_message_at = NEW.created_at,
            message_count = message_count + 1
        WHERE id = NEW.conversation_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE conversations 
        SET message_count = message_count - 1
        WHERE id = OLD.conversation_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for conversation updates on message changes
CREATE TRIGGER trigger_update_conversation_on_message
    AFTER INSERT OR DELETE ON messages
    FOR EACH ROW EXECUTE FUNCTION update_conversation_on_message();

-- Create function to update unread count
CREATE OR REPLACE FUNCTION update_unread_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Increment unread count for all participants except sender
        UPDATE conversation_participants 
        SET unread_count = unread_count + 1
        WHERE conversation_id = NEW.conversation_id 
        AND user_id != NEW.sender_id
        AND status = 'ACTIVE';
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for unread count updates
CREATE TRIGGER trigger_update_unread_count
    AFTER INSERT ON messages
    FOR EACH ROW EXECUTE FUNCTION update_unread_count();

-- Create function to handle read receipts and update unread count
CREATE OR REPLACE FUNCTION handle_read_receipt()
RETURNS TRIGGER AS $$
BEGIN
    -- Update participant's last read message and reset unread count
    UPDATE conversation_participants 
    SET last_read_message_id = NEW.message_id,
        unread_count = 0,
        last_seen_at = NEW.read_at
    WHERE conversation_id = NEW.conversation_id 
    AND user_id = NEW.user_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for read receipt handling
CREATE TRIGGER trigger_handle_read_receipt
    AFTER INSERT ON message_read_receipts
    FOR EACH ROW EXECUTE FUNCTION handle_read_receipt();

-- Create function to clean up expired typing indicators
CREATE OR REPLACE FUNCTION cleanup_expired_typing_indicators()
RETURNS void AS $$
BEGIN
    DELETE FROM typing_indicators WHERE expires_at < CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

-- Create function to create direct conversation between two users
CREATE OR REPLACE FUNCTION create_direct_conversation(user1_id BIGINT, user2_id BIGINT)
RETURNS BIGINT AS $$
DECLARE
    conversation_id BIGINT;
    existing_conversation_id BIGINT;
BEGIN
    -- Check if conversation already exists between these users
    SELECT c.id INTO existing_conversation_id
    FROM conversations c
    JOIN conversation_participants cp1 ON c.id = cp1.conversation_id
    JOIN conversation_participants cp2 ON c.id = cp2.conversation_id
    WHERE c.conversation_type = 'DIRECT'
    AND cp1.user_id = user1_id
    AND cp2.user_id = user2_id
    AND cp1.status = 'ACTIVE'
    AND cp2.status = 'ACTIVE';
    
    IF existing_conversation_id IS NOT NULL THEN
        RETURN existing_conversation_id;
    END IF;
    
    -- Create new conversation
    INSERT INTO conversations (conversation_type, created_by)
    VALUES ('DIRECT', user1_id)
    RETURNING id INTO conversation_id;
    
    -- Add both participants
    INSERT INTO conversation_participants (conversation_id, user_id, role)
    VALUES 
        (conversation_id, user1_id, 'MEMBER'),
        (conversation_id, user2_id, 'MEMBER');
    
    RETURN conversation_id;
END;
$$ LANGUAGE plpgsql;

