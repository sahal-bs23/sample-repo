# 🎓 IIT Jahangirnagar University Alumni Association Web Application

A comprehensive web application for IIT Jahangirnagar University Alumni Association built with modern technologies.

## 🏗️ Architecture Overview

- **Frontend**: React 18 + Redux Toolkit + Tailwind CSS
- **Backend**: Spring Boot 3 + Spring Security + JWT
- **Database**: PostgreSQL 15 with Redis for caching
- **Real-time**: WebSocket for chat, WebRTC for video calls
- **Payments**: Stripe integration
- **Deployment**: Docker containers with docker-compose

## 🚀 Features

### Core Features
- ✅ Multi-provider Authentication (Email, Google, Facebook)
- ✅ Comprehensive Profile Management
- ✅ Event Management with Payment Processing
- ✅ Group Creation and Management
- ✅ Real-time Chat (1-to-1 and Group)
- ✅ Audio/Video Calling
- ✅ Advanced Alumni Search System
- ✅ Mobile Responsive Design

### User Roles
- **Guest**: Browse landing page and sign up
- **Alumni**: Access all features after authentication
- **Admin**: Manage events, groups, and handle reports

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | React + Tailwind CSS |
| State Management | Redux Toolkit |
| Real-time | Socket.IO + WebSocket |
| Backend | Spring Boot + JWT |
| Database | PostgreSQL + Redis |
| Media Storage | AWS S3 / Local Storage |
| Authentication | OAuth2 + JWT |
| Payment Gateway | Stripe |
| Video Calling | WebRTC + PeerJS |
| Deployment | Docker + Docker Compose |

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose
- Node.js 18+ (for local development)
- Java 17+ (for local development)

### Development Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd iitju-alumni-app
   ```

2. **Start with Docker Compose**
   ```bash
   docker-compose up -d
   ```

3. **Access the application**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8080
   - Database: localhost:5432
   - Redis: localhost:6379

### Manual Development Setup

1. **Backend Setup**
   ```bash
   cd backend
   ./mvnw spring-boot:run
   ```

2. **Frontend Setup**
   ```bash
   cd frontend
   npm install
   npm start
   ```

## 📁 Project Structure

```
iitju-alumni-app/
├── frontend/                 # React application
│   ├── src/
│   │   ├── components/      # Reusable components
│   │   ├── pages/          # Page components
│   │   ├── store/          # Redux store
│   │   ├── services/       # API services
│   │   └── utils/          # Utility functions
│   ├── public/
│   └── package.json
├── backend/                 # Spring Boot application
│   ├── src/main/java/
│   │   └── com/iitju/alumni/
│   │       ├── controller/ # REST controllers
│   │       ├── service/    # Business logic
│   │       ├── model/      # Entity models
│   │       ├── repository/ # Data access
│   │       └── config/     # Configuration
│   ├── src/main/resources/
│   └── pom.xml
├── database/               # Database scripts
│   ├── migrations/        # Flyway migrations
│   └── init.sql          # Initial setup
├── docker-compose.yml     # Development environment
└── README.md
```

## 🔧 Configuration

### Environment Variables

Create `.env` files in respective directories:

**Backend (.env)**
```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=alumni_db
DB_USERNAME=alumni_user
DB_PASSWORD=alumni_pass
JWT_SECRET=your-jwt-secret
GOOGLE_CLIENT_ID=your-google-client-id
FACEBOOK_APP_ID=your-facebook-app-id
STRIPE_SECRET_KEY=your-stripe-secret-key
```

**Frontend (.env)**
```
REACT_APP_API_URL=http://localhost:8080/api
REACT_APP_GOOGLE_CLIENT_ID=your-google-client-id
REACT_APP_FACEBOOK_APP_ID=your-facebook-app-id
REACT_APP_STRIPE_PUBLIC_KEY=your-stripe-public-key
```

## 📊 Performance Requirements

- Support for 1000+ concurrent users
- Real-time updates with <1s latency
- Mobile responsive design
- Secure HTTPS communication
- Encrypted password storage

## 🔒 Security Features

- JWT token-based authentication
- OAuth2 integration (Google, Facebook)
- Password encryption with bcrypt
- HTTPS enforcement
- Input validation and sanitization
- CORS configuration

## 🚀 Deployment

### Production Deployment
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### Environment-specific Configurations
- Development: `docker-compose.yml`
- Production: `docker-compose.prod.yml`
- Testing: `docker-compose.test.yml`

## 📝 API Documentation

API documentation is available at:
- Swagger UI: http://localhost:8080/swagger-ui.html
- OpenAPI Spec: http://localhost:8080/v3/api-docs

## 🧪 Testing

### Backend Tests
```bash
cd backend
./mvnw test
```

### Frontend Tests
```bash
cd frontend
npm test
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 📞 Support

For support and questions, please contact the development team.

---

**Built with ❤️ for IIT Jahangirnagar University Alumni**

