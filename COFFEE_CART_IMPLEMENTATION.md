# Coffee Detail & Cart Implementation Plan

## Overview
Adding detailed coffee view functionality and shopping cart system to the Coffink app.

## Features to Implement

### 1. Enhanced Coffee Model
- Add pricing information (base price, size variants)
- Add detailed descriptions, ingredients, nutritional info
- Add size options (Small, Medium, Large)
- Add customization options (milk type, sweetness, temperature)

### 2. Coffee Detail Screen
- Display high-quality coffee image
- Show detailed information (description, ingredients, nutritional facts)
- Size selection with dynamic pricing
- Customization options based on user preferences
- Add to cart functionality with quantity selector
- Reviews and ratings (future enhancement)

### 3. Shopping Cart System
- Cart model for storing items with customizations
- Cart service for managing cart operations (add, remove, update quantity)
- Persistent cart storage using local database
- Cart icon with badge showing item count
- Cart screen for reviewing items before checkout

### 4. Enhanced Logging System
- Structured logging with levels (DEBUG, INFO, WARN, ERROR)
- User action tracking
- Performance monitoring
- Error reporting with context

## Implementation Steps

### Phase 1: Data Models & Services
1. ✅ Update Coffee model with pricing and detailed info
2. ✅ Create CartItem model
3. ✅ Create Cart model
4. ✅ Implement CartService with local storage
5. ✅ Add logging utility

### Phase 2: UI Components
6. ✅ Create CoffeeDetailScreen
7. ✅ Create CartScreen
8. ✅ Update HomeScreen with navigation to details
9. ✅ Add cart icon to AppBar with badge

### Phase 3: Integration & Testing
10. ✅ Integrate cart service with Provider
11. ✅ Add comprehensive logging throughout app
12. ✅ Test all cart operations
13. ✅ Test navigation and data flow

## Database Schema

### Enhanced Coffee Collection
```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "detailedDescription": "string",
  "photoUrl": "string",
  "basePrice": "number",
  "sizes": {
    "small": {"name": "Küçük", "price": 25.0, "ml": 250},
    "medium": {"name": "Orta", "price": 35.0, "ml": 350},
    "large": {"name": "Büyük", "price": 45.0, "ml": 450}
  },
  "ingredients": ["string"],
  "nutritionalInfo": {
    "calories": "number",
    "caffeine": "number",
    "protein": "number"
  },
  "category": "string",
  "isAvailable": "boolean",
  "preparationTime": "number"
}
```

### Cart Items (Local Storage)
```json
{
  "id": "string",
  "coffeeId": "string",
  "coffeeName": "string",
  "coffeeImage": "string",
  "size": "string",
  "price": "number",
  "quantity": "number",
  "customizations": {
    "milkType": "string",
    "sweetness": "number",
    "temperature": "string",
    "extraShots": "number"
  },
  "addedAt": "datetime"
}
```

## UI/UX Considerations

### Coffee Detail Screen
- Hero image with zoom capability
- Sticky add-to-cart button at bottom
- Smooth animations for customization changes
- Price updates in real-time
- Turkish localization for all text

### Cart Screen
- Swipe to delete items
- Quantity adjustment with +/- buttons
- Order summary with taxes
- Empty cart state with suggestions
- Checkout button (placeholder for future payment integration)

## Logging Implementation

### Log Levels
- **DEBUG**: Development debugging info
- **INFO**: User actions, navigation, successful operations
- **WARN**: Recoverable errors, deprecated usage
- **ERROR**: Unrecoverable errors, exceptions

### Log Categories
- **USER_ACTION**: Button clicks, navigation, purchases
- **DATA**: API calls, database operations
- **PERFORMANCE**: Loading times, memory usage
- **ERROR**: Exceptions, failed operations

### Example Log Entries
```
[INFO] [USER_ACTION] User navigated to coffee detail: Cappuccino
[DEBUG] [DATA] Loading coffee details from Firestore: coffee_id_123
[INFO] [USER_ACTION] Added to cart: Cappuccino, Large, Oat Milk, Sweet
[ERROR] [DATA] Failed to load coffee details: NetworkException
```

## Error Handling

### Network Errors
- Show user-friendly error messages in Turkish
- Retry mechanisms for failed requests
- Offline mode with cached data

### Cart Operations
- Validate stock availability before adding to cart
- Handle concurrent cart modifications
- Graceful degradation if cart service fails

## Performance Optimizations

### Image Loading
- Lazy loading for coffee images
- Image caching and compression
- Placeholder images while loading

### Data Management
- Efficient Firestore queries with pagination
- Local caching of frequently accessed data
- Optimistic UI updates for cart operations

## Future Enhancements (Not in this implementation)
- User reviews and ratings
- Coffee recommendations based on taste preferences
- Loyalty program integration
- Real-time order tracking
- Push notifications for order updates
- Social sharing of favorite coffees

## Testing Strategy

### Unit Tests
- Cart service operations
- Price calculations
- Data model validation

### Integration Tests
- Navigation between screens
- Cart persistence across app restarts
- Firebase integration

### User Acceptance Tests
- Complete user journey from browsing to adding to cart
- Customization options work correctly
- Turkish localization is complete and accurate