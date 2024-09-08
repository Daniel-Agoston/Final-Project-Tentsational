import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"; //import this to use new flatpickr()

export default class extends Controller {
  connect() {

    flatpickr(this.element)
  }
}
