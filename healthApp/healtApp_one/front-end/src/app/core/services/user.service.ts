import { Injectable } from '@angular/core';
import {HttpClient, HttpErrorResponse} from '@angular/common/http';
import {Globals} from '../../globals';
import {Observable} from 'rxjs/Rx';

@Injectable()
export class UserService {

	private baseurl = '';

	constructor(private http: HttpClient, private globals: Globals) {
		this.baseurl  = globals.baseurl;
	}
  
  	doChangePassword(parameter):Observable<any>{
    	return this.http.post<any> (this.baseurl+'/user/do-change-password',parameter);
    }

	userLogin(details):Observable<any> {
		console.log(details);
		return this.http.post<any> (this.baseurl+'',details);
	}
}
