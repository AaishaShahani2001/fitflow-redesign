# fitflow-redesign
FitFlow Redesign – HCI Lab 05 Technology Stack and System Architecture

# FitFlow Redesign

FitFlow Redesign is an HCI project focused on redesigning a fitness
application with improved usability, personalization, performance,
and cross-platform accessibility.

## Key Features

- Personalized AI workout plans
- Workout and progress tracking
- Nutrition tracking
- Community and social features
- Real-time updates
- Secure user authentication

## Technology Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter |
| Backend | NestJS |
| AI Service | FastAPI / Python |
| Database | PostgreSQL |
| Authentication | Supabase Auth |
| Caching | Redis |
| Real-Time | NestJS WebSockets |

## Project Structure

fitflow-redesign/
├── frontend/
├── backend/
├── ai-service/
└── docs/
    ├── architecture/
    ├── comparison-matrix/
    └── adr/

## Architecture

FitFlow uses a service-oriented architecture. Flutter provides the
cross-platform user interface, NestJS handles the main backend
services, and FastAPI provides AI-powered workout recommendations.

PostgreSQL stores application data, Redis provides caching, and
WebSockets support real-time community features.

See the `docs/architecture` directory for the architecture diagram.

## Documentation

- Technology Stack Summary
- Technology Comparison Matrix
- High-Level Architecture
- Architecture Decision Record (ADR)

## Academic Project

Developed as part of the IT3060 – Human Computer Interaction module.