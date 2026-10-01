# Collection

This is how a device moves from a household or an organization into the network. Dispatch rules, price, and the status clash are not resolved here.

The household or organization asks for a pickup and gives a time window and the collection details. An administrator, or a dispatcher, assigns the request to an eligible agent. The agent travels, confirms the person and the device, records the collection, and hands the device on. A collection point is a place where devices can be received and recorded.

Who counts as an eligible agent is [TBD]. "Dispatch mechanism" in the definition does not by itself mean the assignment is automatic.

## What the household does

Pick one or more registered devices. Give the collection details. Pick or give a time window. Submit.

The definition does not list the fields inside "collection details". The agent later needs a location and a way to contact the requester, because those are agent features. Anything past that is [TBD].

## What the agent does

Receive the assignment. Go to the location. Confirm the requester. Confirm the device. Record the collection. Update the status. Move the device to the next stage.

The agent may also register a device that is not registered yet, capture details, take required photos, do a preliminary assessment, and record the handover. Required photos are [TBD].

## Statuses

```text
REQUESTED
ASSIGNED
ACCEPTED
EN_ROUTE
ARRIVED
COLLECTED
CANCELLED
FAILED
COMPLETED
```

These names are not a sequence. The definition does not say which status may follow another. `CANCELLED` and `FAILED` have no defined entry or exit. `COLLECTED` and `COMPLETED` are both named and not distinguished. That is C-01.

Which role may move which status is not written status by status.

## Against the device lifecycle

The request has its own status. The device has lifecycle states such as `COLLECTION_REQUESTED`, `COLLECTION_ASSIGNED`, `COLLECTED`, and `RECEIVED`.

Those lists are not mapped. See C-02 in [../product/requirements.md](../product/requirements.md). Product and operations still have to agree which event means the agent has the device, the request is finished, and the next place has received it.

If the assignment is already on the phone, the agent can record the collection with no network. The official record appears when the server accepts the sync.

Organizations can request a bulk collection. Staffing, vehicles, and how that differs from a household request are [TBD].

No fee, incentive payment, or free-of-charge rule is defined. Do not put a charge on the collection flow.
