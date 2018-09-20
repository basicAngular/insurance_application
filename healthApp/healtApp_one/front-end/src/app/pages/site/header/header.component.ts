import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { FormGroup, AbstractControl} from '@angular/forms';


@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.scss']
})
export class HeaderComponent {
  public router: Router;
  public form:FormGroup;
  public email:AbstractControl;
  public password:AbstractControl;

  constructor() {

  }
  
}
