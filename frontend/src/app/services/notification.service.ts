import { Injectable, signal } from '@angular/core';

export interface Notification {
  id: string;
  type: 'success' | 'error' | 'warning' | 'info';
  message: string;
  duration?: number;
}

@Injectable({
  providedIn: 'root'
})
export class NotificationService {
  notifications = signal<Notification[]>([]);

  show(message: string, type: Notification['type'] = 'info', duration = 5000) {
    const id = Math.random().toString(36).substring(7);
    const notification: Notification = { id, type, message, duration };
    
    this.notifications.update(notifications => [...notifications, notification]);

    if (duration > 0) {
      setTimeout(() => this.remove(id), duration);
    }
  }

  success(message: string, duration = 5000) {
    this.show(message, 'success', duration);
  }

  error(message: string, duration = 7000) {
    this.show(message, 'error', duration);
  }

  warning(message: string, duration = 6000) {
    this.show(message, 'warning', duration);
  }

  info(message: string, duration = 5000) {
    this.show(message, 'info', duration);
  }

  remove(id: string) {
    this.notifications.update(notifications => 
      notifications.filter(n => n.id !== id)
    );
  }

  clear() {
    this.notifications.set([]);
  }
}
