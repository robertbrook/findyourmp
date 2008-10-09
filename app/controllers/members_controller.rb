class MembersController < ResourceController::Base

  belongs_to :constituency

  protected

  def object
    parent_object.member
  end

  def object_url
    send 'constituency_url', parent_object
  end
end
