# Assumptions:

1. One house per lot. A lot belongs to exactly one subdivision; a house is ultimately built on at most one lot.
2. One elevation per built house. Houses are of a single style and a single elevation variant.
3. Price snapshots. BasePrice is copied into the Sale at contract time; option prices are stage-dependent and stored in OptionStagePrice. DecoratorChoice stores the final chosen price as a snapshot.
4. Contract timing. A sale/contract may occur before construction; therefore a House can exist with stage=0/“not started,” or you can allow Sale to exist before ConstructionProgress starts.
5. Bank info is optional. A buyer may finance via one bank/contact captured on the Sale; modeling multiple lenders is out of scope.
6. Documents received checkboxes on the Sale represent simple Booleans; if you need a full audit, make a related table.
7. Employees. Sales reps and (optional) construction managers are both in the Employee table; you can subtype if desired.
8. Stages reference. Stages are a 1..7 fixed lookup; tasks are representative “major tasks” per stage.
9. Decorator sessions. Choices can be captured in multiple sessions over time; the session header carries the date, employee, and stage context.
- This is because the real jobs differ; lets you budget vs. track actuals without touching the template.
10. Decoration and Construction both require progress to be recorded
11. BaseCost differs with Price given that Price is what the customer pays for an option of the task
12. Specific rooms cannot have decorators
13. All decorator prices are the same for every style
14. Can only fill addresses and description to only 1000 characters
15. ID's are only 10 digits, and numerical
