export enum ProductCategory {
  Electronics = 1,
  Clothing = 2,
  Food = 3,
  Furniture = 4,
  OfficeSupplies = 5,
  Other = 6
}

export enum UserRole {
  Admin = 1,
  Manager = 2,
  Clerk = 3
}

export enum ReportType {
  Summary = 1,
  ByCategory = 2,
  LowStock = 3,
  InventoryValue = 4
}

export const CATEGORY_NAMES: Record<ProductCategory, string> = {
  [ProductCategory.Electronics]: 'Electronics',
  [ProductCategory.Clothing]: 'Clothing',
  [ProductCategory.Food]: 'Food',
  [ProductCategory.Furniture]: 'Furniture',
  [ProductCategory.OfficeSupplies]: 'Office Supplies',
  [ProductCategory.Other]: 'Other'
};

export const ROLE_NAMES: Record<UserRole, string> = {
  [UserRole.Admin]: 'Admin',
  [UserRole.Manager]: 'Manager',
  [UserRole.Clerk]: 'Clerk/Supervisor'
};

export const REPORT_NAMES: Record<ReportType, string> = {
  [ReportType.Summary]: 'Summary Report',
  [ReportType.ByCategory]: 'Report by Category',
  [ReportType.LowStock]: 'Low Stock Alert Report',
  [ReportType.InventoryValue]: 'Inventory Value Report'
};

export const VALIDATION = {
  SKU_PATTERN: /^[A-Z]{3}-[A-Z0-9]{4}-[A-Z0-9]{4}$/,
  SKU_LENGTH: 14,
  PRICE_MIN: 0.01,
  PRICE_MAX: 999999.99,
  QUANTITY_MIN: 0,
  QUANTITY_MAX: 999999,
  REORDER_MIN: 0,
  REORDER_MAX: 999999,
  PRODUCT_NAME_MAX: 100,
  DESCRIPTION_MAX: 500,
  USERNAME_MAX: 50,
  PASSWORD_MIN: 6,
  MAX_LOGIN_ATTEMPTS: 3
};

export const APP_INFO = {
  NAME: 'Inventory Management System',
  VERSION: '2.0.0',
  DESCRIPTION: 'Angular 19 Migration of VB6 Inventory Management System',
  ORIGINAL: 'Originally developed in Visual Basic 6.0',
  MIGRATED_BY: 'Devin AI',
  FRAMEWORK: 'Angular 19 with Standalone Components'
};

export const CATEGORY_PREFIXES: Record<ProductCategory, string> = {
  [ProductCategory.Electronics]: 'ELC',
  [ProductCategory.Clothing]: 'CLT',
  [ProductCategory.Food]: 'FOD',
  [ProductCategory.Furniture]: 'FRN',
  [ProductCategory.OfficeSupplies]: 'OFS',
  [ProductCategory.Other]: 'OTH'
};

export const DEMO_ACCOUNT_NAMES = ['admin', 'manager', 'clerk'];
export const DEMO_ACCOUNT_LABELS = ['System Administrator', 'Inventory Manager', 'Inventory Clerk'];
export const DEMO_ACCOUNT_ROLES = [UserRole.Admin, UserRole.Manager, UserRole.Clerk];
export const DEMO_CREDENTIAL_SUFFIX = '123';
