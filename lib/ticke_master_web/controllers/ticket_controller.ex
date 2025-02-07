defmodule TickeMasterWeb.TicketController do
  use TickeMasterWeb, :controller

  alias TickeMaster.TicketServer

  # API to book a ticket
  def book(conn, %{"ticket_id" => ticket_id}) do
    case TicketServer.book_ticket(String.to_integer(ticket_id)) do
      {:ok, msg} -> json(conn, %{status: "success", message: msg})
      {:error, msg} -> json(conn, %{status: "error", message: msg})
    end
  end

  # API to sell a ticket
  def sell(conn, %{"ticket_id" => ticket_id}) do
    case TicketServer.sell_ticket(String.to_integer(ticket_id)) do
      {:ok, msg} -> json(conn, %{status: "success", message: msg})
      {:error, msg} -> json(conn, %{status: "error", message: msg})
    end
  end

  # API to check available tickets
  def available(conn, _params) do
    count = TicketServer.available_tickets()
    json(conn, %{available_tickets: count})
  end
end
