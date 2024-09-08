import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="basket"

export default class extends Controller {
  static targets = ["basket", "datebutton", "spacer", "quantitySelector", "finalQuantity", "finalPrice", "totalPrice"]

  toggle() {
    this.basketTarget.classList.toggle("d-none")
    this.spacerTarget.classList.toggle("d-none")
    this.changeButtonStyle()
  }

  changeButtonStyle() {
    this.datebuttonTarget.classList.toggle("btn-info")
    this.datebuttonTarget.classList.toggle("d-none")
  }

  updateFinalBasket() {
    const quantity = parseInt(this.quantitySelectorTarget.value)
    const price = parseFloat(this.finalPriceTarget.dataset.price)
    const total = quantity * price

    this.finalQuantityTarget.textContent = quantity
    this.finalPriceTarget.textContent = `£${(price * quantity).toFixed(2)}`
    this.totalPriceTarget.textContent = `£${(total).toFixed(2)}`
  }
};
