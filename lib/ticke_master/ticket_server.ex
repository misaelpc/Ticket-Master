defmodule TickeMaster.TicketServer do
  use GenServer

  ## -- Public API -- ##

  # Start the GenServer with an initial set of tickets
  def start_link(initial_tickets) do
    GenServer.start_link(__MODULE__, initial_tickets, name: __MODULE__)
  end

  # Book a ticket (temporary hold)
  def book_ticket(ticket_id) do
    GenServer.call(__MODULE__, {:book, ticket_id})
  end

  # Sell a ticket (confirm the booking)
  def sell_ticket(ticket_id) do
    GenServer.call(__MODULE__, {:sell, ticket_id})
  end

  # Check available tickets
  def available_tickets do
    GenServer.call(__MODULE__, :available_tickets)
  end

  ## -- GenServer Callbacks -- ##

  # Initialize with available tickets
  def init(ticket_count) do
    # Initial state: A map where all tickets are :available
    tickets = for i <- 1..ticket_count, into: %{}, do: {i, :available}
    {:ok, tickets}
  end

  # Handle booking a ticket
  def handle_call({:book, ticket_id}, _from, tickets) do
    case Map.get(tickets, ticket_id) do
      :available ->
        {:reply, {:ok, "Ticket #{ticket_id} booked"}, Map.put(tickets, ticket_id, :booked)}

      :booked ->
        {:reply, {:error, "Ticket #{ticket_id} is already booked"}, tickets}

      :sold ->
        {:reply, {:error, "Ticket #{ticket_id} has already been sold"}, tickets}

      nil ->
        {:reply, {:error, "Ticket #{ticket_id} does not exist"}, tickets}
    end
  end

  # Handle selling a ticket
  def handle_call({:sell, ticket_id}, _from, tickets) do
    case Map.get(tickets, ticket_id) do
      :booked ->
        {:reply, {:ok, "Ticket #{ticket_id} sold"}, Map.put(tickets, ticket_id, :sold)}

      :available ->
        {:reply, {:error, "Ticket #{ticket_id} must be booked first"}, tickets}

      :sold ->
        {:reply, {:error, "Ticket #{ticket_id} has already been sold"}, tickets}

      nil ->
        {:reply, {:error, "Ticket #{ticket_id} does not exist"}, tickets}
    end
  end

  # Handle checking available tickets
  def handle_call(:available_tickets, _from, tickets) do
    available = Enum.filter(tickets, fn {_id, status} -> status == :available end) |> Enum.count()
    {:reply, available, tickets}
  end
end
