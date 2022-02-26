# frozen_string_literal: true

# Controller which handles all actions related to licenses
class LicensesController < ApplicationController
  def index; end

  def add
    license = License.create license_params
    redirect_to licenses_versions_path(id: license.id)
  end

  def license_params
    params.permit(:paid_till, :min_version, :max_version)
          .transform_values { |v| v.empty? ? nil : v }
  end

  def versions
    license = License.find params[:id]
    last_year, last_month = FlussonicLastVersion.get.split('.').map(&:to_i)
    filtered_versions = filter_versions last_month, last_year, license
    response = (filtered_versions.empty? ? [default_max_version(license)] : filtered_versions)
               .map { |month, year| "#{format '%02d', year % 100}.#{format '%02d', month}" }
               .reverse
    render json: response
  end

  def all_versions(month, year)
    Enumerator.new do |y|
      loop do
        y << [month, year]
        month -= 1
        if month.zero?
          month = 12
          year -= 1
        end
      end
    end
  end

  def filter_versions(last_month, last_year, license)
    paid_till = license.paid_till
    all_versions(last_month, last_year)
      .take(5)
      .reject { |month, year| wrong_version? month, year, paid_till.month, paid_till.year % 100, :< }
      .reject { |month, year| wrong_limit_version? month, year, license.max_version, :< }
      .reject { |month, year| wrong_limit_version? month, year, license.min_version, :> }
  end

  def default_max_version(license)
    if license.max_version
      license.max_version.split('.').reverse.map(&:to_i)
    else
      [license.paid_till.month, license.paid_till.year]
    end
  end

  def wrong_limit_version?(month, year, date, operator)
    return false unless date

    curr_year, curr_month = date.split('.').map(&:to_i)
    wrong_version? month, year, curr_month, curr_year, operator
  end

  def wrong_version?(month, year, curr_month, curr_year, operator)
    curr_year.__send__(operator, year) || (curr_year == year && curr_month.__send__(operator, month))
  end
end
