import { ProductCategory, CATEGORY_NAMES } from './constants';

export interface Product {
  productId: number;
  sku: string;
  productName: string;
  description: string;
  category: ProductCategory;
  unitPrice: number;
  quantityInStock: number;
  reorderLevel: number;
  dateAdded: Date;
  lastModified: Date;
  isActive: boolean;
}

export function createDefaultProduct(): Product {
  return {
    productId: 0,
    sku: '',
    productName: '',
    description: '',
    category: ProductCategory.Other,
    unitPrice: 0,
    quantityInStock: 0,
    reorderLevel: 10,
    dateAdded: new Date(),
    lastModified: new Date(),
    isActive: true
  };
}

export function isLowStock(product: Product): boolean {
  return product.quantityInStock <= product.reorderLevel && product.quantityInStock > 0;
}

export function isOutOfStock(product: Product): boolean {
  return product.quantityInStock === 0;
}

export function totalValue(product: Product): number {
  return product.unitPrice * product.quantityInStock;
}

export function getStockStatus(product: Product): string {
  if (product.quantityInStock === 0) {
    return 'Out of Stock';
  }
  if (product.quantityInStock <= product.reorderLevel) {
    return 'Low Stock';
  }
  return 'In Stock';
}

export function getCategoryName(category: ProductCategory): string {
  return CATEGORY_NAMES[category] || 'Unknown';
}
