class AttrisController < ApplicationController

  before_action :set_attri, only: [:show, :edit, :update, :destroy]

  def index
  	  @attris = Attri.all
     render json: @attris.as_json
  end

  def show
     render json: @attri.as_json
  end

  def new
    @attri = Attri.new
  end

  def destroy
    attri = Attri.find(params[:id])
    attri.destroy
    render text: "destroyed"
   end

   def create
    @attri = Attri.new(attri_params)
    if @attri.save
        render json: @attri 
   else
       render json: @attri.errors, status: :unprocessable_entity
    end
   end
 
   def update
      if @attri.update(attri_params)
         @attri.save
         render json: @attri
      end
   end

   def findMfiles

    attri = Attri.find(params[:id])
    if attri != nil
      render json: attri.mfiles
    end

  end
 
  private

  def set_attri
    @attri = Attri.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def attri_params
    params.require(:attri).permit(:name, :agroup_id, :id_sort, :parent_id, :keycode)
  end


end
