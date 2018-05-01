module Kapa::CalendarEventsControllerBase
  extend ActiveSupport::Concern
  # before_action :set_event, only [:show, :edit, :update, :destroy]

  def index
    @event = Kapa::CalendarEvent.where(start: params[:start]..params[:end])
  end

  def show
  end

  def new
    @event = Kapa::CalendarEvent.new
  end

  def create
    @event = Kapa::CalendarEvent.new(event_params)
    @event.save
  end

  def update
    @event.update(event_params)
  end

  def destroy
    @event.destroy
  end

  private
    def set_event
      @event = Kapa::CalendarEvent.find(params[:id])
    end

    def event_params
      params.require(:event).permit(:title, :start, :end)
    end
end
