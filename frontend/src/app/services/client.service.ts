import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface Client {
  id: string;
  companyName: string;
  contactName: string;
  email: string;
  phone: string;
  address?: string;
  taxId?: string;
  notes?: string;
  createdAt: string;
}

export interface CreateClientDto {
  companyName: string;
  contactName: string;
  email: string;
  phone: string;
  address: string;
  taxId?: string;
}

@Injectable({
  providedIn: 'root'
})
export class ClientService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrl}/clients`;

  getAll(): Observable<Client[]> {
    return this.http.get<Client[]>(this.apiUrl);
  }

  getById(id: string): Observable<Client> {
    return this.http.get<Client>(`${this.apiUrl}/${id}`);
  }

  create(client: CreateClientDto): Observable<Client> {
    return this.http.post<Client>(this.apiUrl, client);
  }

  update(id: string, client: CreateClientDto): Observable<Client> {
    return this.http.put<Client>(`${this.apiUrl}/${id}`, { id, ...client });
  }

  delete(id: string): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }
}
