# Decentralized-Disaster-Recovery-Fund
Overview

The Decentralized Disaster Recovery Fund (D-DRF) is a smart contract on the Stacks blockchain designed to provide disaster recovery funds through a decentralized model. The fund is supported by donations and enables individuals or organizations to submit claims for disaster relief. The contract is governed by a fund creator (administrator), who verifies claims before releasing funds.

This contract supports the following features:

Donations from users to build up the fund.

The ability for users to submit claims for disaster recovery.

Claim verification and payouts managed by the contract creator.

Transparency of donations, claims, and fund status.

Features

Fund Initialization: The creator initializes the fund, which can only be done once.

Donations: Users can donate STX to the disaster recovery fund. The contract tracks donations.

Claims: Users can submit claims for disaster relief. Claims are stored and can be verified by the creator.

Claim Verification: The creator (admin) can verify and approve claims for payout.

Transparency: View fund status and claim details via public methods.

Contract Functions
1. initialize-fund

Description: Initializes the disaster recovery fund. This can only be done once by the contract creator.

Input: None

Returns: true if successful; err if the fund has already been initialized.

Permissions: Only the contract creator can initialize the fund.

2. donate(amount)

Description: Allows users to donate a specified amount of STX to the fund. The minimum donation is set by the contract creator.

Input:

amount: The amount of STX to donate (in micro-STX).

Returns:

true if the donation is successful.

err ERR-INVALID-DONATION if the donation amount is less than the minimum allowed.

Permissions: Open to all users.

3. submit-claim(amount)

Description: Allows any user to submit a claim for disaster relief funds. Claims can only be submitted while the fund is active.

Input:

amount: The amount requested in the claim (in micro-STX).

Returns:

The claim ID if successful.

err ERR-CLAIM-INVALID if the claim amount is invalid or the fund is inactive.

Permissions: Open to all users.

4. verify-claim(claim-id, is-approved)

Description: Allows the contract creator to verify and approve or reject claims. If approved, the claim amount is transferred from the fund.

Input:

claim-id: The ID of the claim to verify.

is-approved: A boolean indicating whether the claim is approved.

Returns:

true if the claim is successfully verified and paid out.

err ERR-ALREADY-CLAIMED if the claim has already been verified.

err ERR-NO-FUNDS if there are insufficient funds to approve the claim.

Permissions: Only the contract creator can verify claims.

5. get-fund-status

Description: Returns the current status of the disaster recovery fund, including the total funds, whether the fund is active, and the creator.

Returns: A tuple containing:

total-funds: The total amount available in the fund.

is-active: A boolean indicating whether the fund is active.

creator: The address of the contract creator.

Permissions: Public (open to everyone).

6. get-claim-status(claim-id)

Description: Returns the details of a claim, including the claimant, amount, verification status, and whether it has been paid.

Input:

claim-id: The ID of the claim to retrieve.

Returns: A tuple containing:

reporter: The principal address of the person who made the claim.

amount: The amount requested in the claim.

is-verified: A boolean indicating if the claim was verified.

is-paid: A boolean indicating if the claim was paid.

Permissions: Public (open to everyone).

Error Codes

ERR-INVALID-DONATION (u100): Raised when a donation is less than the minimum allowed donation.

ERR-ALREADY-CLAIMED (u101): Raised when attempting to verify a claim that has already been verified.

ERR-UNAUTHORIZED (u102): Raised when a non-creator tries to execute creator-only functions.

ERR-CLAIM-INVALID (u103): Raised when an invalid claim is submitted or the fund is inactive.

ERR-NO-FUNDS (u104): Raised when there are insufficient funds to pay out a claim.

ERR-NOT-INITIALIZED (u105): Raised if a function is called before the fund is initialized.

Data Structures
fund-status

key: Always u0 (the key for the fund).

total-funds: The total available funds in the disaster recovery fund (in micro-STX).

is-active: A boolean indicating whether the fund is active.

creator: The principal address of the contract creator.

claims

claim-id: The unique identifier for each claim.

reporter: The principal address of the person submitting the claim.

amount: The amount requested in the claim (in micro-STX).

is-verified: A boolean indicating whether the claim has been verified.

is-paid: A boolean indicating whether the claim has been paid.

donations

donor: The principal address of the donor.

amount: The amount donated (in micro-STX).

claim-counter

A variable tracking the current claim ID, incremented with each new claim.

Usage Example
Initialize the Fund:
initialize-fund()

Donate to the Fund:
donate(500)  ;; Donate 500 micro-STX

Submit a Claim:
submit-claim(200)  ;; Submit a claim for 200 micro-STX

Verify a Claim:
verify-claim(1, true)  ;; Approve claim with ID 1

View Fund Status:
get-fund-status()  ;; Get the current fund status

View Claim Status:
get-claim-status(1)  ;; Get the status of claim with ID 1

Deployment

To deploy the contract:

Compile the Clarity code using the Stacks CLI or any Clarity-compatible IDE.

Deploy the contract to the Stacks blockchain via the Stacks wallet or any tool that supports Clarity deployment.

License

This contract is released under the MIT License.
