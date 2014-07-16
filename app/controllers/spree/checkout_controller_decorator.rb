Spree::CheckoutController.class_eval do

  Spree::PermittedAttributes.checkout_attributes << :gift_code

  durably_decorate :update, mode: 'soft', sha: '332cd434375588dd3c5a65841694b506946171f8' do
    if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
      if @order.gift_code.present?
        render :edit and return unless apply_gift_code
      end

      persist_user_address
      unless @order.next
        flash[:error] = @order.errors.full_messages.join("\n")
        redirect_to checkout_state_path(@order.state) and return
      end

      if @order.completed?
        @current_order = nil
        flash.notice = Spree.t(:order_processed_successfully)
        flash[:order_completed] = true
        redirect_to completion_route
      else
        redirect_to checkout_state_path(@order.state)
      end
    else
      render :edit
    end

  end

end
