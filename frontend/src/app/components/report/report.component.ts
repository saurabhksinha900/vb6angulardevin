import { Component, EventEmitter, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { InventoryService } from '../../services/inventory.service';
import { ReportType, REPORT_NAMES } from '../../models/constants';

@Component({
  selector: 'app-report',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './report.component.html',
  styleUrls: ['./report.component.scss']
})
export class ReportComponent {
  @Output() close = new EventEmitter<void>();

  selectedReportType: ReportType = ReportType.Summary;
  reportContent = '';
  reportTypes = Object.entries(REPORT_NAMES)
    .filter(([key]) => !isNaN(Number(key)))
    .map(([key, name]) => ({ value: Number(key) as ReportType, name }));

  constructor(private inventoryService: InventoryService) {}

  generateReport(): void {
    this.reportContent = this.inventoryService.generateReport(this.selectedReportType);
  }

  exportReport(): void {
    if (!this.reportContent) {
      return;
    }
    const blob = new Blob([this.reportContent], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `inventory-report-${Date.now()}.txt`;
    a.click();
    URL.revokeObjectURL(url);
  }

  onClose(): void {
    this.close.emit();
  }
}
