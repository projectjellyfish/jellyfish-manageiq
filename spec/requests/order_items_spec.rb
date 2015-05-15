require 'rails_helper'

RSpec.describe 'Order Items API' do
  let(:default_params) { { format: :json } }
  let(:project) { create :project }
  let(:product) { create :product }

  before(:each) do
    @order = Order.create(staff_id: 1, order_items_attributes: [{ product_id: product.id, project_id: project.id }, { product_id: create(:product).id, project_id: create(:project).id }])
    sign_in_as create :staff, :admin
    @order_item = @order.order_items.first
  end

  describe 'Item service start / stop' do
    it 'can be started', :show_in_doc do
      put "/api/v1/order_items/#{@order_item.id}/start_service"
      expect(response.status).to eq(200)
    end

    it 'can be stopped', :show_in_doc do
      put "/api/v1/order_items/#{@order_item.id}/stop_service"
      expect(response.status).to eq(200)
    end
  end

  describe 'PUT provision request response' do
    before :each do
      @order = Order.create(staff_id: 1, order_items_attributes: [{ product_id: product.id, project_id: project.id }])
      @order_item = @order.order_items.first
      @payload =
      {
        status: 'OK',
        message: '',
        info: {
          provision_status: 'ok',
          uuid: @order_item.uuid.to_s
        }
      }
    end

    it 'updates the order item with the payload and its data' do
      put "/api/v1/order_items/#{@order_item.id}/provision_update", @payload.to_json, HTTP_ACCEPT: 'application/json', CONTENT_TYPE: 'application/json'
      expect(response.status).to eq(204)
    end

    it 'returns an error when the order item does not exist' do
      put "/api/v1/order_items/#{@order_item.id + 999}/provision_update", @payload.to_json, HTTP_ACCEPT: 'application/json', CONTENT_TYPE: 'application/json'
      expect(response.status).to eq(404)
      expect(json).to eq('error' => 'Not found.')
    end

    it 'with missing or invalid parameters' do
      put "/api/v1/order_items/#{@order_item.id}/provision_update"
      expect(response.status).to eq(422)
    end
  end
end
