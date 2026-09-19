# ADR-001: FitFlow High-Level Architecture

## Status

Accepted

## Context

FitFlow requires a scalable and maintainable architecture that supports
Android, iOS and web applications.

The system must support personalized AI workout recommendations,
nutrition tracking, progress monitoring, secure authentication and
real-time community features.

## Decision

The following technology architecture was selected:

- Flutter for the cross-platform frontend
- NestJS for the primary backend API
- FastAPI/Python for the AI microservice
- PostgreSQL for the primary database
- Supabase Auth for authentication
- Redis for caching
- NestJS WebSockets for real-time communication

The AI functionality is separated from the main backend so that
AI-related services can be developed and scaled independently.

## Alternatives Considered

The following alternatives were evaluated:

- React Native, Kotlin Multiplatform and SwiftUI for frontend development
- FastAPI and Go as alternatives to NestJS for the primary backend
- MongoDB, Firestore and DynamoDB for database management
- Firebase Auth, Auth0 and AWS Cognito for authentication

## Reasons for the Decision

The selected architecture provides:

- Cross-platform support
- Good application performance
- Strong scalability
- AI/ML integration
- Secure authentication
- Real-time communication
- Structured data management
- Good maintainability

## Consequences

### Positive

- High frontend code reuse
- AI service can scale independently
- PostgreSQL supports structured FitFlow data
- Redis improves frequently accessed data performance
- WebSockets support real-time community features

### Negative

- Multiple backend services increase deployment complexity
- The development team must maintain both TypeScript and Python services
- Additional monitoring is required for distributed components

## Final Decision

Flutter + NestJS + FastAPI + PostgreSQL + Supabase Auth +
Redis + WebSockets will be used as the proposed architecture
for the FitFlow redesign.