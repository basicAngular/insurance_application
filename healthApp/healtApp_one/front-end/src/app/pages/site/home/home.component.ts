import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { FormGroup, AbstractControl} from '@angular/forms';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.scss']
})
export class HomeComponent {
  public router: Router;
  public form:FormGroup;
  public email:AbstractControl;
  public password:AbstractControl;

  constructor() {

  }


}
