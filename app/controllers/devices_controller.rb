class DevicesController < ApplicationController

  def show
    device = find_device
    if device.present?
      render json: {device: device}, status: 200
    else
      render json: {error: "Not found"}, status: 404
    end
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
    @device = find_device
    @device.update_attributes(device_params)
    redirect_to @device
  end

  def destroy
  end

  def device_settings
    device = find_device
    render json: {settings: device.permitted_settings}, status: 200
  end

  private

  def device_params
    params.require(:device).permit(:authentication_token, :name, :turn_on_time, :turn_off_time, :intensity, :on_temperature, :off_temperature, :on_volume, :off_volume, :group, :temperature_set, :status, :on)
  end

  def find_device
    Device.friendly.find(params[:id])
  end

end
