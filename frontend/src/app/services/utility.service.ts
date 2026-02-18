import { Injectable } from '@angular/core';
import { VALIDATION } from '../models/constants';

@Injectable({
  providedIn: 'root'
})
export class UtilityService {

  formatCurrency(amount: number): string {
    return '$' + amount.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  }

  isValidSKU(sku: string): boolean {
    if (!sku || sku.length !== VALIDATION.SKU_LENGTH) {
      return false;
    }
    return VALIDATION.SKU_PATTERN.test(sku);
  }

  isValidPrice(value: number): boolean {
    return !isNaN(value) && value >= VALIDATION.PRICE_MIN && value <= VALIDATION.PRICE_MAX;
  }

  isValidQuantity(value: number): boolean {
    return !isNaN(value) &&
      Number.isInteger(value) &&
      value >= VALIDATION.QUANTITY_MIN &&
      value <= VALIDATION.QUANTITY_MAX;
  }

  isValidReorderLevel(value: number): boolean {
    return !isNaN(value) &&
      Number.isInteger(value) &&
      value >= VALIDATION.REORDER_MIN &&
      value <= VALIDATION.REORDER_MAX;
  }

  isValidProductName(name: string): boolean {
    return !!name && name.trim().length > 0 && name.length <= VALIDATION.PRODUCT_NAME_MAX;
  }

  isValidDescription(description: string): boolean {
    return description.length <= VALIDATION.DESCRIPTION_MAX;
  }

  formatDate(date: Date): string {
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    });
  }

  formatDateTime(date: Date): string {
    return date.toLocaleString('en-US', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    });
  }

  padString(text: string, length: number): string {
    return text.padEnd(length);
  }
}
