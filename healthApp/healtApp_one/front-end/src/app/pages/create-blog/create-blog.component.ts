import { Component, OnInit, ViewEncapsulation } from '@angular/core';

@Component({
  selector: 'app-create-blog',
  templateUrl: './create-blog.component.html',
  styleUrls: ['./create-blog.component.scss'],
  encapsulation: ViewEncapsulation.None
})
export class CreateBlogComponent implements OnInit {
  public config:any;
  public ckeditorContent;
  constructor() {
    this.ckeditorContent = '<div>Hey we are testing CKEditor</div>';
    this.config = {
      uiColor: '#F0F3F4',
      height: '350',
      extraPlugins: 'divarea'
    };
  }

  onChange(event: any) {
    setTimeout(() => {
      console.log(this.ckeditorContent);
      this.ckeditorContent = event;
    });
  }
  onReady(event: any) { }
  onFocus(event: any) {
    console.log("editor is focused");
  }
  onBlur(event: any) {
  }

  ngOnInit() {
  }

}
