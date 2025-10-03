# Expense Management System - Project Structure

## 📁 Complete Folder Structure

```
expense-management-system/
├── app/                                    # Next.js App Router
│   ├── (auth)/                            # Authentication pages
│   │   ├── login/
│   │   │   └── page.js                    # Login page
│   │   ├── signup/
│   │   │   └── page.js                    # Signup page
│   │   ├── forgot-password/
│   │   │   └── page.js                    # Forgot password page
│   │   ├── reset-password/
│   │   │   └── page.js                    # Reset password page
│   │   └── layout.js                      # Auth layout
│   │
│   ├── dashboard/                         # Main dashboard
│   │   ├── layout.js                      # Dashboard layout
│   │   ├── page.js                        # Dashboard home
│   │   ├── profile/
│   │   │   └── page.js                    # User profile
│   │   ├── settings/
│   │   │   └── page.js                    # User settings
│   │   ├── notifications/
│   │   │   └── page.js                    # Notifications
│   │   │
│   │   ├── employee/                      # Employee dashboard
│   │   │   ├── layout.js                  # Employee layout
│   │   │   ├── page.js                    # Employee home
│   │   │   ├── submit-expense/
│   │   │   │   └── page.js                # Submit expense
│   │   │   ├── my-expenses/
│   │   │   │   └── page.js                # My expenses
│   │   │   ├── expense-history/
│   │   │   │   └── page.js                # Expense history
│   │   │   └── expense-details/
│   │   │       └── [id]/
│   │   │           └── page.js            # Expense details
│   │   │
│   │   ├── manager/                       # Manager dashboard
│   │   │   ├── layout.js                  # Manager layout
│   │   │   ├── page.js                    # Manager home
│   │   │   ├── approvals/
│   │   │   │   └── page.js                # Pending approvals
│   │   │   ├── team-expenses/
│   │   │   │   └── page.js                # Team expenses
│   │   │   ├── approval-history/
│   │   │   │   └── page.js                # Approval history
│   │   │   └── expense-details/
│   │   │       └── [id]/
│   │   │           └── page.js            # Manager expense details
│   │   │
│   │   └── admin/                         # Admin dashboard
│   │       ├── layout.js                  # Admin layout
│   │       ├── page.js                    # Admin home
│   │       ├── users/
│   │       │   ├── page.js                # User management
│   │       │   ├── create/
│   │       │   │   └── page.js            # Create user
│   │       │   └── edit/
│   │       │       └── [id]/
│   │       │           └── page.js        # Edit user
│   │       ├── approval-rules/
│   │       │   ├── page.js                # Approval rules management
│   │       │   ├── create/
│   │       │   │   └── page.js            # Create approval rule
│   │       │   └── edit/
│   │       │       └── [id]/
│   │       │           └── page.js        # Edit approval rule
│   │       ├── expense-categories/
│   │       │   ├── page.js                # Expense categories management
│   │       │   ├── create/
│   │       │   │   └── page.js            # Create category
│   │       │   └── edit/
│   │       │       └── [id]/
│   │       │           └── page.js        # Edit category
│   │       ├── expenses/
│   │       │   ├── page.js                # All expenses (admin view)
│   │       │   └── [id]/
│   │       │       └── page.js            # Admin expense details
│   │       ├── reports/
│   │       │   └── page.js                # Reports
│   │       ├── settings/
│   │       │   └── page.js                # Company settings
│   │       └── audit-logs/
│   │           └── page.js                # Audit logs
│   │
│   └── api/                               # API Routes
│       ├── auth/
│       │   ├── login/
│       │   │   └── route.js               # Login API
│       │   ├── signup/
│       │   │   └── route.js               # Signup API
│       │   ├── logout/
│       │   │   └── route.js               # Logout API
│       │   ├── forgot-password/
│       │   │   └── route.js               # Forgot password API
│       │   ├── reset-password/
│       │   │   └── route.js               # Reset password API
│       │   └── verify-email/
│       │       └── route.js               # Email verification API
│       │
│       ├── expenses/
│       │   ├── route.js                   # Expenses CRUD API
│       │   ├── [id]/
│       │   │   └── route.js               # Individual expense API
│       │   ├── [id]/approve/
│       │   │   └── route.js               # Approve expense API
│       │   └── [id]/reject/
│       │       └── route.js               # Reject expense API
│       │
│       ├── approvals/
│       │   ├── route.js                   # Approvals API
│       │   ├── pending/
│       │   │   └── route.js               # Pending approvals API
│       │   └── history/
│       │       └── route.js               # Approval history API
│       │
│       ├── users/
│       │   ├── route.js                   # Users CRUD API
│       │   ├── [id]/
│       │   │   └── route.js               # Individual user API
│       │   └── [id]/expenses/
│       │       └── route.js               # User expenses API
│       │
│       ├── expense-categories/
│       │   ├── route.js                   # Categories CRUD API
│       │   └── [id]/
│       │       └── route.js               # Individual category API
│       │
│       ├── approval-workflows/
│       │   ├── route.js                   # Workflows CRUD API
│       │   └── [id]/
│       │       └── route.js               # Individual workflow API
│       │
│       ├── notifications/
│       │   ├── route.js                   # Notifications API
│       │   └── [id]/read/
│       │       └── route.js               # Mark notification as read
│       │
│       └── reports/
│           ├── expenses/
│           │   └── route.js               # Expense reports API
│           ├── approvals/
│           │   └── route.js               # Approval reports API
│           └── users/
│               └── route.js               # User reports API
│
├── backend/                               # Backend Services
│   ├── controllers/                       # Controllers
│   │   ├── authController.js              # Authentication controller
│   │   ├── userController.js              # User controller
│   │   ├── expenseController.js           # Expense controller
│   │   ├── approvalController.js          # Approval controller
│   │   ├── notificationController.js      # Notification controller
│   │   ├── reportController.js            # Report controller
│   │   ├── companyController.js           # Company controller
│   │   └── settingsController.js          # Settings controller
│   │
│   ├── routes/                            # Routes
│   │   ├── authRoutes.js                  # Authentication routes
│   │   ├── userRoutes.js                  # User routes
│   │   ├── expenseRoutes.js               # Expense routes
│   │   ├── approvalRoutes.js              # Approval routes
│   │   ├── notificationRoutes.js          # Notification routes
│   │   ├── reportRoutes.js                # Report routes
│   │   ├── companyRoutes.js               # Company routes
│   │   ├── settingsRoutes.js              # Settings routes
│   │   └── index.js                       # Main routes index
│   │
│   ├── middleware/                        # Middleware
│   │   ├── auth.js                        # Authentication middleware
│   │   ├── roleAuth.js                    # Role-based auth middleware
│   │   ├── validation.js                  # Input validation middleware
│   │   ├── errorHandler.js                # Error handling middleware
│   │   └── rateLimiter.js                 # Rate limiting middleware
│   │
│   ├── services/                          # Business Logic Services
│   │   ├── authService.js                 # Authentication service
│   │   ├── expenseService.js              # Expense service
│   │   ├── approvalService.js             # Approval service
│   │   ├── notificationService.js         # Notification service
│   │   ├── emailService.js                # Email service
│   │   └── reportService.js               # Report service
│   │
│   ├── utils/                             # Utilities
│   │   ├── constants.js                   # Application constants
│   │   ├── helpers.js                     # Helper functions
│   │   ├── validators.js                  # Validation functions
│   │   ├── logger.js                      # Logging utility
│   │   └── currencyConverter.js           # Currency conversion utility
│   │
│   ├── config/                            # Configuration
│   │   ├── database.js                    # Database configuration
│   │   ├── email.js                       # Email configuration
│   │   ├── redis.js                       # Redis configuration
│   │   └── aws.js                         # AWS configuration
│   │
│   ├── app.js                             # Main application file
│   └── server.js                          # Server entry point
│
├── models/                                # MongoDB Models
│   ├── User.js                            # User model
│   ├── Company.js                         # Company model
│   ├── ExpenseCategory.js                 # Expense category model
│   ├── Expense.js                         # Expense model
│   ├── ApprovalWorkflow.js                # Approval workflow model
│   ├── ApprovalRule.js                    # Approval rule model
│   ├── ConditionalApprovalRule.js         # Conditional approval rule model
│   ├── ExpenseApproval.js                 # Expense approval model
│   ├── ConditionalApproval.js             # Conditional approval model
│   ├── Notification.js                    # Notification model
│   ├── SystemSetting.js                   # System setting model
│   └── index.js                           # Model exports
│
├── components/                            # React Components
│   ├── ui/                                # UI Components
│   │   ├── Button.js                      # Button component
│   │   ├── Input.js                       # Input component
│   │   ├── Modal.js                       # Modal component
│   │   ├── Table.js                       # Table component
│   │   └── Form.js                        # Form component
│   │
│   ├── layout/                            # Layout Components
│   │   ├── Header.js                      # Header component
│   │   ├── Sidebar.js                     # Sidebar component
│   │   └── Footer.js                      # Footer component
│   │
│   ├── forms/                             # Form Components
│   │   ├── ExpenseForm.js                 # Expense form
│   │   ├── UserForm.js                    # User form
│   │   └── ApprovalForm.js                # Approval form
│   │
│   └── dashboard/                         # Dashboard Components
│       ├── ExpenseCard.js                 # Expense card
│       ├── ApprovalCard.js                # Approval card
│       ├── StatsCard.js                   # Stats card
│       └── NotificationCard.js            # Notification card
│
├── hooks/                                 # Custom Hooks
│   ├── useAuth.js                         # Authentication hook
│   ├── useExpenses.js                     # Expenses hook
│   ├── useApprovals.js                    # Approvals hook
│   └── useNotifications.js                # Notifications hook
│
├── contexts/                              # React Contexts
│   ├── AuthContext.js                     # Authentication context
│   ├── ExpenseContext.js                  # Expense context
│   └── NotificationContext.js             # Notification context
│
├── utils/                                 # Frontend Utilities
│   ├── api.js                             # API utility functions
│   ├── constants.js                       # Frontend constants
│   ├── helpers.js                         # Helper functions
│   └── validators.js                      # Validation functions
│
├── middleware/                            # Next.js Middleware
│   ├── auth.js                            # Authentication middleware
│   ├── roleAuth.js                        # Role-based auth middleware
│   └── rateLimiter.js                     # Rate limiting middleware
│
├── lib/                                   # Libraries
│   └── db.js                              # Database connection
│
├── public/                                # Static Assets
│   ├── images/                            # Images
│   ├── icons/                             # Icons
│   └── favicon.ico                        # Favicon
│
├── styles/                                # Styles
│   ├── globals.css                        # Global styles
│   ├── components.css                     # Component styles
│   └── pages.css                          # Page styles
│
├── tests/                                 # Tests
│   ├── unit/                              # Unit tests
│   ├── integration/                       # Integration tests
│   └── e2e/                               # End-to-end tests
│
├── docs/                                  # Documentation
│   ├── api/                               # API documentation
│   ├── components/                        # Component documentation
│   └── deployment/                        # Deployment guides
│
├── .env.local                             # Environment variables
├── .env.example                           # Environment variables example
├── .gitignore                             # Git ignore file
├── .eslintrc.json                         # ESLint configuration
├── .prettierrc                            # Prettier configuration
├── next.config.js                         # Next.js configuration
├── package.json                           # Dependencies
├── README.md                              # Project documentation
└── PROJECT_STRUCTURE.md                   # This file
```

## 🎯 Key Features by Folder

### **Authentication (`app/(auth)/`)**
- Login, Signup, Password Reset
- Email Verification
- Auth-specific layout

### **Dashboard (`app/dashboard/`)**
- **Employee**: Submit expenses, view history, check status
- **Manager**: Approve expenses, view team data, manage approvals
- **Admin**: User management, system configuration, reports

### **API Routes (`app/api/`)**
- RESTful API endpoints
- Authentication and authorization
- CRUD operations for all entities
- Report generation endpoints

### **Backend Services (`backend/`)**
- **Controllers**: Handle HTTP requests
- **Services**: Business logic implementation
- **Routes**: API endpoint definitions
- **Middleware**: Authentication, validation, error handling
- **Utils**: Helper functions and utilities

### **MongoDB Models (`models/`)**
- Complete database schema
- Business logic methods
- Data validation
- Relationship management

### **React Components (`components/`)**
- **UI**: Reusable interface components
- **Layout**: Page structure components
- **Forms**: Data input components
- **Dashboard**: Feature-specific components

### **Custom Hooks (`hooks/`)**
- State management
- API integration
- Business logic encapsulation

### **Contexts (`contexts/`)**
- Global state management
- Cross-component data sharing

## 🚀 Ready for Development

All files are created as templates and ready for implementation. The structure follows Next.js 14 App Router conventions and includes:

- ✅ Complete page structure
- ✅ API route organization
- ✅ Backend service architecture
- ✅ MongoDB model definitions
- ✅ Component hierarchy
- ✅ Middleware setup
- ✅ Utility organization

## 📝 Next Steps

1. **Implement API Routes**: Add business logic to API route files
2. **Create Components**: Build React components with actual functionality
3. **Add Controllers**: Implement backend controller logic
4. **Setup Services**: Create business logic services
5. **Configure Middleware**: Add authentication and validation
6. **Style Components**: Add CSS/styling to components
7. **Add Tests**: Create unit and integration tests
8. **Deploy**: Setup deployment configuration

The project structure is now complete and ready for development!
