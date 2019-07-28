class AgroupsController < ApplicationController

  before_action :set_Agroup, only: [:show, :edit, :update, :destroy]

  def index
  	  @agroups = Agroup.all
     render json: @agroups.as_json
  end

  def show
     render json: @agroup.as_json
  end

  def new
    @agroup = Agroup.new
  end

  def destroy
    agroup = Agroup.find(params[:id])
    agroup.destroy
    render text: "destroyed"
   end

   def create
    @agroup = Agroup.new(Agroup_params)
    if @agroup.save
        render json: @agroup 
   else
       render json: @agroup.errors, status: :unprocessable_entity
    end
   end
 
   def update
      if @agroup.update(Agroup_params)
         @agroup.save
         render json: @agroup
      end
   end

   def findMfiles

    agroup = Agroup.find(params[:id])
    if agroup != nil
      render json: agroup.mfiles
    end

  end
 
  private

  def set_agroup
    @agroup = Agroup.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def Agroup_params
    params.require(:agroup).permit(:name, :agroup_id, :id_sort, :parent_id, :keycode)
  end


end
