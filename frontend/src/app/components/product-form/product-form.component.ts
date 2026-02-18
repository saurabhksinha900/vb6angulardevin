import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { InventoryService } from '../../services/inventory.service';
import { UtilityService } from '../../services/utility.service';
import { AuthService } from '../../services/auth.service';
import { Product, createDefaultProduct } from '../../models/product.model';
import { canEditProducts } from '../../models/user.model';
import { ProductCategory, CATEGORY_NAMES, VALIDATION } from '../../models/constants';

@Component({
  selector: 'app-product-form',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './product-form.component.html',
  styleUrls: ['./product-form.component.scss']
})
export class ProductFormComponent implements OnInit {
  product: Product = createDefaultProduct();
  isEditMode = false;
  errorMessage = '';
  successMessage = '';
  categories = Object.entries(CATEGORY_NAMES).map(([key, name]) => ({ value: Number(key) as ProductCategory, name }));
  validation = VALIDATION;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private inventoryService: InventoryService,
    private utilityService: UtilityService,
    private authService: AuthService
  ) {}

  ngOnInit(): void {
    const user = this.authService.getCurrentUser();
    if (!user || !canEditProducts(user)) {
      this.router.navigate(['/dashboard']);
      return;
    }

    const idParam = this.route.snapshot.paramMap.get('id');
    if (idParam && idParam !== 'new') {
      const id = Number(idParam);
      const existing = this.inventoryService.getProductById(id);
      if (existing) {
        this.product = { ...existing };
        this.isEditMode = true;
      } else {
        this.router.navigate(['/dashboard']);
      }
    }
  }

  generateSku(): void {
    this.product.sku = this.inventoryService.generateSku(this.product.category);
  }

  onCategoryChange(): void {
    if (!this.isEditMode) {
      this.generateSku();
    }
  }

  validate(): string[] {
    const errors: string[] = [];
    if (!this.utilityService.isValidProductName(this.product.productName)) {
      errors.push('Product name is required (max 100 characters).');
    }
    if (!this.utilityService.isValidSKU(this.product.sku)) {
      errors.push('SKU must be in format XXX-XXXX-XXXX (letters and digits).');
    }
    if (!this.inventoryService.isSkuUnique(this.product.sku, this.isEditMode ? this.product.productId : undefined)) {
      errors.push('SKU already exists.');
    }
    if (!this.utilityService.isValidPrice(this.product.unitPrice)) {
      errors.push(`Price must be between $${VALIDATION.PRICE_MIN} and $${VALIDATION.PRICE_MAX.toLocaleString()}.`);
    }
    if (!this.utilityService.isValidQuantity(this.product.quantityInStock)) {
      errors.push(`Quantity must be between ${VALIDATION.QUANTITY_MIN} and ${VALIDATION.QUANTITY_MAX.toLocaleString()}.`);
    }
    if (!this.utilityService.isValidReorderLevel(this.product.reorderLevel)) {
      errors.push(`Reorder level must be between ${VALIDATION.REORDER_MIN} and ${VALIDATION.REORDER_MAX.toLocaleString()}.`);
    }
    return errors;
  }

  onSubmit(): void {
    this.errorMessage = '';
    this.successMessage = '';

    const errors = this.validate();
    if (errors.length > 0) {
      this.errorMessage = errors.join(' ');
      return;
    }

    let success: boolean;
    if (this.isEditMode) {
      success = this.inventoryService.updateProduct(this.product);
    } else {
      success = this.inventoryService.addProduct(this.product);
    }

    if (success) {
      this.router.navigate(['/dashboard']);
    } else {
      this.errorMessage = 'Failed to save product. Please try again.';
    }
  }

  cancel(): void {
    this.router.navigate(['/dashboard']);
  }
}
