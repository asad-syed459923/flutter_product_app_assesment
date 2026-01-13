Flutter Technical Assessment

This project is developed as part of a Flutter technical assessment.  
The goal of the application is to demonstrate clean architecture, scalable state management, offline caching, and testing best practices.

 Application Overview
- Product List
- Pagination
- Search with debouncing
- Pull-to-refresh
- Favorites with local persistence
- Theme switching (Light / Dark / System)
- Localization (English / Urdu)
- Offline caching
- Error and empty state handling

API Used:  
https://dummyjson.com/products

 Architecture Choice

 Clean Architecture (Simplified)

The project follows a **Clean Architecture** approach with separation into:


 Why Clean Architecture?
- Separates business logic from UI


State Management Choice
 GetX

GetX is used for:

- State management
- Dependency injection
- Routing
- Theme and localization

 Why GetX?

- Minimal boilerplate
- Reactive programming using `Obx`
- Built-in dependency injection
- Easy to test controllers independently

 GetX Supports:

- Pagination via reactive state
- Real-time favorites updates
- Theme switching
- Offline behavior with cached data

 API Handling

- API calls are handled using `Dio`
- Pagination implemented using `skip` and `limit`
- States handled:
  - Loading
  - Error
  - Empty
- Missing or null fields are handled gracefully using fallback values (`N/A`, `0`, empty string)

 Caching Strategy

Local Storage: Hive

The following data is cached locally:

| Data | Storage |

| Products | Hive |
| Favorites | Hive |
| Theme | Hive |
| Localization | Hive |

 Fetch Strategy

- Internet-first
- Cached data used when offline
- Favorites and settings persist across app restarts
  

 UI / UX Design

- Clean and minimal UI
- Consistent spacing and typography
- Pull-to-refresh and infinite scrolling
- Clear loading, error, and empty states
- Smooth navigation using GetX routing


 Testing Strategy

- Unit Tests
  - Controllers
  - Repositories
- Widget Tests
  - UI rendering
  - State changes

