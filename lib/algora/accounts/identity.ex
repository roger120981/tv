defmodule Algora.Accounts.Identity do
  use Ecto.Schema
  import Ecto.Changeset

  alias Algora.Accounts.{Identity, User}

  # providers
  @github "github"
  @restream "restream"

  @derive {Inspect, except: [:provider_token, :provider_refresh_token, :provider_meta]}
  schema "identities" do
    field :provider, :string
    field :provider_token, :string
    field :provider_refresh_token, :string
    field :provider_email, :string
    field :provider_login, :string
    field :provider_name, :string, virtual: true
    field :provider_id, :string
    field :provider_meta, :map

    belongs_to :user, User

    timestamps()
  end

  @doc """
  sets up a changeset for oauth.
  for now, its just Google. Perhaps, more providers in the future?
  """
  def changeset(identity, attrs) do
    identity
    |> cast(attrs, [:provider, :provider_id, :provider_token, :provider_email, :provider_login, :provider_refresh_token])
    |> validate_required([:provider, :provider_token, :provider_id, :provider_email])
    |> validate_length(:provider, min: 1)
  end

  @doc """
  A user changeset for github registration.
  """
  def github_registration_changeset(info, primary_email, emails, token) do
    params = %{
      "provider_token" => token,
      "provider_id" => to_string(info["id"]),
      "provider_login" => info["login"],
      "provider_name" => info["name"] || info["login"],
      "provider_email" => primary_email
    }

    %Identity{provider: @github, provider_meta: %{"user" => info, "emails" => emails}}
    |> cast(params, [
      :provider_token,
      :provider_email,
      :provider_login,
      :provider_name,
      :provider_id
    ])
    |> validate_required([:provider_token, :provider_email, :provider_name, :provider_id])
    |> validate_length(:provider_meta, max: 10_000)
  end

  @doc """
  A user changeset for restream oauth.
  """
  def restream_oauth_changeset(info, user_id, %{token: token, refresh_token: refresh_token}) do
    params = %{
      "provider_token" => token,
      "provider_refresh_token" => refresh_token,
      "provider_id" => to_string(info["id"]),
      "provider_login" => info["username"],
      "provider_name" => info["username"],
      "provider_email" => info["email"],
      "user_id" => user_id
    }

    %Identity{provider: @restream, provider_meta: %{"user" => info}}
    |> cast(params, [
      :provider_token,
      :provider_refresh_token,
      :provider_email,
      :provider_login,
      :provider_name,
      :provider_id,
      :user_id
    ])
    |> validate_required([
      :provider_token,
      :provider_refresh_token,
      :provider_email,
      :provider_name,
      :provider_id,
      :user_id
    ])
    |> validate_length(:provider_meta, max: 10_000)
  end
end
