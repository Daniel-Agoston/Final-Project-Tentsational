import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="calander"
export default class extends Controller {
  connect() {
    console.log("Calandar controller connected!")
  }
}
