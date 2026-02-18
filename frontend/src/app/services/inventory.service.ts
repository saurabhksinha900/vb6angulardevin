import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';
import { Product, totalValue, isLowStock, isOutOfStock, getCategoryName } from '../models/product.model';
import { ProductCategory, CATEGORY_NAMES, CATEGORY_PREFIXES, VALIDATION } from '../models/constants';

@Injectable({
  providedIn: 'root'
})
export class InventoryService {
  private products$ = new BehaviorSubject<Product[]>([]);
  private nextId = 11;

  constructor() {
    this.initSeedData();
  }

  private initSeedData(): void {
    const now = new Date();
    const seedProducts: Product[] = [
      {
        productId: 1, sku: 'ELC-1001-ABCD', productName: 'Wireless Mouse',
        description: 'Ergonomic wireless mouse with USB receiver',
        category: ProductCategory.Electronics, unitPrice: 29.99, quantityInStock: 150,
        reorderLevel: 25, dateAdded: now, lastModified: now, isActive: true
      },
      {
        productId: 2, sku: 'ELC-1002-EFGH', productName: 'USB Keyboard',
        description: 'Mechanical USB keyboard with backlight',
        category: ProductCategory.Electronics, unitPrice: 59.99, quantityInStock: 8,
        reorderLevel: 15, dateAdded: now, lastModified: now, isActive: true
      },
      {
        productId: 3, sku: 'CLT-2001-IJKL', productName: 'Cotton T-Shirt',
        description: '100% cotton crew neck t-shirt',
        category: ProductCategory.Clothing, unitPrice: 19.99, quantityInStock: 200,
        reorderLevel: 50, dateAdded: now, lastModified: now, isActive: true
      },
      {
        productId: 4, sku: 'CLT-2002-MNOP', productName: 'Denim Jeans',
        description: 'Classic fit denim jeans',
        category: ProductCategory.Clothing, unitPrice: 49.99, quantityInStock: 75,
        reorderLevel: 20, dateAdded: now, lastModified: now, isActive: true
      },
      {
        productId: 5, sku: 'FOD-3001-QRST', productName: 'Organic Coffee Beans',
        description: '1lb bag of organic fair-trade coffee beans',
        category: ProductCategory.Food, unitPrice: 14.99, quantityInStock: 0,
        reorderLevel: 30, dateAdded: now, lastModified: now, isActive: true
      },
      {
        productId: 6, sku: 'FOD-3002-UVWX', productName: 'Granola Bars (Box)',
        description: 'Box of 12 assorted granola bars',
        category: ProductCategory.Food, unitPrice: 8.99, quantityInStock: 45,
        reorderLevel: 40, dateAdded: now, lastModified: now, isActive: true
      },
      {
        productId: 7, sku: 'FRN-4001-YZAB', productName: 'Office Desk Chair',
        description: 'Adjustable ergonomic office chair',
        category: ProductCategory.Furniture, unitPrice: 249.99, quantityInStock: 12,
        reorderLevel: 5, dateAdded: now, lastModified: now, isActive: true
      },
      {
        productId: 8, sku: 'FRN-4002-CDEF', productName: 'Standing Desk',
        description: 'Electric height-adjustable standing desk',
        category: ProductCategory.Furniture, unitPrice: 499.99, quantityInStock: 3,
        reorderLevel: 5, dateAdded: now, lastModified: now, isActive: true
      },
      {
        productId: 9, sku: 'OFS-5001-GHIJ', productName: 'Printer Paper (Ream)',
        description: '500 sheets of white multipurpose printer paper',
        category: ProductCategory.OfficeSupplies, unitPrice: 7.99, quantityInStock: 500,
        reorderLevel: 100, dateAdded: now, lastModified: now, isActive: true
      },
      {
        productId: 10, sku: 'OFS-5002-KLMN', productName: 'Ballpoint Pens (12-pack)',
        description: 'Pack of 12 black ballpoint pens',
        category: ProductCategory.OfficeSupplies, unitPrice: 5.99, quantityInStock: 10,
        reorderLevel: 20, dateAdded: now, lastModified: now, isActive: true
      }
    ];
    this.products$.next(seedProducts);
  }

  getProducts(): Product[] {
    return this.products$.value;
  }

  getProducts$() {
    return this.products$.asObservable();
  }

  getProductById(id: number): Product | undefined {
    return this.products$.value.find(p => p.productId === id);
  }

  addProduct(product: Product): boolean {
    const products = [...this.products$.value];
    if (!this.isSkuUnique(product.sku)) {
      return false;
    }
    product.productId = this.nextId++;
    product.dateAdded = new Date();
    product.lastModified = new Date();
    product.isActive = true;
    products.push(product);
    this.products$.next(products);
    return true;
  }

  updateProduct(product: Product): boolean {
    const products = [...this.products$.value];
    const index = products.findIndex(p => p.productId === product.productId);
    if (index === -1) {
      return false;
    }
    if (!this.isSkuUnique(product.sku, product.productId)) {
      return false;
    }
    product.lastModified = new Date();
    products[index] = product;
    this.products$.next(products);
    return true;
  }

  deleteProduct(id: number): boolean {
    const products = this.products$.value.filter(p => p.productId !== id);
    if (products.length === this.products$.value.length) {
      return false;
    }
    this.products$.next(products);
    return true;
  }

  searchProducts(name: string, category: ProductCategory | null): Product[] {
    let results = this.products$.value.filter(p => p.isActive);
    if (name && name.trim()) {
      const searchTerm = name.toLowerCase().trim();
      results = results.filter(p =>
        p.productName.toLowerCase().includes(searchTerm) ||
        p.sku.toLowerCase().includes(searchTerm)
      );
    }
    if (category !== null) {
      results = results.filter(p => p.category === category);
    }
    return results;
  }

  getProductCount(): number {
    return this.products$.value.filter(p => p.isActive).length;
  }

  getTotalInventoryValue(): number {
    return this.products$.value
      .filter(p => p.isActive)
      .reduce((sum, p) => sum + totalValue(p), 0);
  }

  getLowStockCount(): number {
    return this.products$.value.filter(p => p.isActive && isLowStock(p)).length;
  }

  getOutOfStockCount(): number {
    return this.products$.value.filter(p => p.isActive && isOutOfStock(p)).length;
  }

  isSkuUnique(sku: string, excludeId?: number): boolean {
    return !this.products$.value.some(
      p => p.sku.toLowerCase() === sku.toLowerCase() && p.productId !== excludeId
    );
  }

  generateSummaryReport(): string {
    const products = this.products$.value.filter(p => p.isActive);
    const lines: string[] = [];
    lines.push('=== INVENTORY SUMMARY REPORT ===');
    lines.push(`Generated: ${new Date().toLocaleString()}`);
    lines.push('');
    lines.push(`Total Products: ${products.length}`);
    lines.push(`Total Inventory Value: $${this.getTotalInventoryValue().toFixed(2)}`);
    lines.push(`Low Stock Items: ${this.getLowStockCount()}`);
    lines.push(`Out of Stock Items: ${this.getOutOfStockCount()}`);
    lines.push('');
    lines.push('--- Product List ---');
    lines.push(this.padString('ID', 6) + this.padString('SKU', 16) + this.padString('Name', 30) +
      this.padString('Price', 12) + this.padString('Qty', 8) + this.padString('Value', 14) + 'Status');
    lines.push('-'.repeat(100));
    for (const p of products) {
      const status = isOutOfStock(p) ? 'OUT OF STOCK' : isLowStock(p) ? 'LOW STOCK' : 'In Stock';
      lines.push(
        this.padString(p.productId.toString(), 6) +
        this.padString(p.sku, 16) +
        this.padString(p.productName.substring(0, 28), 30) +
        this.padString('$' + p.unitPrice.toFixed(2), 12) +
        this.padString(p.quantityInStock.toString(), 8) +
        this.padString('$' + totalValue(p).toFixed(2), 14) +
        status
      );
    }
    lines.push('');
    lines.push('=== END OF REPORT ===');
    return lines.join('\n');
  }

  generateCategoryReport(): string {
    const products = this.products$.value.filter(p => p.isActive);
    const lines: string[] = [];
    lines.push('=== INVENTORY BY CATEGORY REPORT ===');
    lines.push(`Generated: ${new Date().toLocaleString()}`);
    lines.push('');

    const categories = Object.values(ProductCategory).filter(v => typeof v === 'number') as ProductCategory[];
    for (const cat of categories) {
      const catProducts = products.filter(p => p.category === cat);
      if (catProducts.length === 0) continue;
      const catName = getCategoryName(cat);
      const catValue = catProducts.reduce((sum, p) => sum + totalValue(p), 0);
      lines.push(`--- ${catName} (${catProducts.length} items, Value: $${catValue.toFixed(2)}) ---`);
      for (const p of catProducts) {
        lines.push(`  ${p.sku}  ${this.padString(p.productName, 30)}  Qty: ${p.quantityInStock}  Price: $${p.unitPrice.toFixed(2)}`);
      }
      lines.push('');
    }
    lines.push('=== END OF REPORT ===');
    return lines.join('\n');
  }

  generateLowStockReport(): string {
    const products = this.products$.value.filter(p => p.isActive && (isLowStock(p) || isOutOfStock(p)));
    const lines: string[] = [];
    lines.push('=== LOW STOCK ALERT REPORT ===');
    lines.push(`Generated: ${new Date().toLocaleString()}`);
    lines.push('');
    lines.push(`Items Requiring Attention: ${products.length}`);
    lines.push('');

    if (products.length === 0) {
      lines.push('No low stock or out of stock items found.');
    } else {
      lines.push(this.padString('SKU', 16) + this.padString('Name', 30) +
        this.padString('Qty', 8) + this.padString('Reorder', 10) + 'Status');
      lines.push('-'.repeat(80));
      for (const p of products) {
        const status = isOutOfStock(p) ? '** OUT OF STOCK **' : 'LOW STOCK';
        lines.push(
          this.padString(p.sku, 16) +
          this.padString(p.productName.substring(0, 28), 30) +
          this.padString(p.quantityInStock.toString(), 8) +
          this.padString(p.reorderLevel.toString(), 10) +
          status
        );
      }
    }
    lines.push('');
    lines.push('=== END OF REPORT ===');
    return lines.join('\n');
  }

  generateValueReport(): string {
    const products = this.products$.value.filter(p => p.isActive);
    const lines: string[] = [];
    lines.push('=== INVENTORY VALUE REPORT ===');
    lines.push(`Generated: ${new Date().toLocaleString()}`);
    lines.push('');

    const sorted = [...products].sort((a, b) => totalValue(b) - totalValue(a));
    lines.push(this.padString('SKU', 16) + this.padString('Name', 30) +
      this.padString('Price', 12) + this.padString('Qty', 8) + this.padString('Total Value', 14));
    lines.push('-'.repeat(80));

    for (const p of sorted) {
      lines.push(
        this.padString(p.sku, 16) +
        this.padString(p.productName.substring(0, 28), 30) +
        this.padString('$' + p.unitPrice.toFixed(2), 12) +
        this.padString(p.quantityInStock.toString(), 8) +
        '$' + totalValue(p).toFixed(2)
      );
    }
    lines.push('');
    lines.push(`TOTAL INVENTORY VALUE: $${this.getTotalInventoryValue().toFixed(2)}`);
    lines.push('');
    lines.push('=== END OF REPORT ===');
    return lines.join('\n');
  }

  generateReport(type: number): string {
    switch (type) {
      case 1: return this.generateSummaryReport();
      case 2: return this.generateCategoryReport();
      case 3: return this.generateLowStockReport();
      case 4: return this.generateValueReport();
      default: return 'Invalid report type.';
    }
  }

  generateSku(category: ProductCategory): string {
    const prefix = CATEGORY_PREFIXES[category] || 'OTH';
    const num = Math.floor(1000 + Math.random() * 9000);
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let suffix = '';
    for (let i = 0; i < 4; i++) {
      suffix += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return `${prefix}-${num}-${suffix}`;
  }

  private padString(text: string, length: number): string {
    return text.padEnd(length);
  }
}
