# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class OrganisationsController < ApplicationController
  before_filter :check_authorization!
  before_filter :reset_tenant
  before_filter :destroy_organisation_session!, :except => [ :select, :edit, :update, :edit_preferences, :update_preferences ]

  respond_to :html, :xml, :json
  # GET /organisations
  # GET /organisations.xml
  def index
    destroy_organisation_session!

    @organisations = current_user.organisations
    if current_user.organisations.any?
      set_organisation_session(current_user.organisations.first)
      @currency_rates = CurrencyRate.current_hash
      render "/dashboard/index"
    else
      reset_org
      session[:step] = params[:step] || 1
      session[:max_step] ||= 1

      send(:"get_step_#{session[:step]}")
      render :action => 'new'
    end
  end

  # GET /organisations/1
  # GET /organisations/1.xml
  def show
    session[:organisation] = nil
    @organisation = Organisation.find(params[:id])
    respond_with(@organisation)
  end

  # GET /organisations/new
  def new
    session[:organisation] = nil
    @organisation = Organisation.new(:currency_id => 1)
  end

  # GET /organisations/:id/schema
  def check_schema
    res = !!PgTools.set_search_path(params[:id])
    render :json => {:success => res, :id => params[:id]}
  end

  # POST /organisations
  def create
    @organisation = Organisation.new(params[:organisation])

    if @organisation.save
      flash[:notice] = "Se ha creado su empresa correctamente."
      job = Resque.enqueue CreateTenant, @organisation.id
      redirect_to @organisation
    else
      render 'new'
    end
  end

  # GET /organisations/:id/create_tenant
  def create_tenant
    @organisation = Organisation.find(params[:id])
    job = Resque.enqueue CreateTenant, @organisation.id
    render "show"
  end

  # GET /organisations/1/edit
  def edit
    @organisation = Organisation.find(session[:organisation][:id])
    respond_with(@organisation)
  end

  # PUT /organisations/1
  # PUT /organisations/1.xml
  def update
    @organisation = Organisation.find(session[:organisation][:id])
    if @organisation.update_attributes(params[:organisation])
      set_organisation_session @organisation
      flash[:notice] = "Se ha actualizado correctamente los datos de su empresa."

      redirect_to "/configuration#organisation"
    else
      render :action => 'edit'
    end
  end

  # GET /organisation/1/select
  # sets the organisation session
  def select
    begin
      @organisation = current_user.organisations.find(params[:id])
      redirect_to 
    rescue
      flash[:error] = "Usted no puede registrarse"
      redirect_to "/users/sign_in"
    end
  end

  private

  def reset_tenant
    PgTools.restore_default_search_path
  end
end
