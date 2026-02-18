import { Component, EventEmitter, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { APP_INFO } from '../../models/constants';

@Component({
  selector: 'app-about',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './about.component.html',
  styleUrls: ['./about.component.scss']
})
export class AboutComponent {
  @Output() close = new EventEmitter<void>();

  appInfo = APP_INFO;

  onClose(): void {
    this.close.emit();
  }
}
