# Swarma Rent, draft 0.2: notes for the lead

Second iteration of the research task T15 (rental service on the Swarma
platform and Swarma Link). The book is in `book/ru/` (15 chapters, Russian is
the source of truth) and builds to `book/swarma-rent.ru.pdf` (119 pages).
This file is a working summary; it is not part of the book.

Sources checked for this draft: Link specification 0.1.43, the Link book
(title line 0.6, release candidate 4), the platform book 2.0, Swarma Curator
documentation 0.15.0-rc.9, the owner's answers of 2026-11-14 and the
decisions handoff of the same date.

## What changed in v0.2

1. **Grants v4 only.** Every grant and contract mechanism is rewritten
   against the v4 drafts: LIP-0008 (grant v4), LIP-0017 (contracts),
   LIP-0020 (wire registry and consent), LIP-0021 (name ownership and
   history), LIP-0022 (observation, freshness, depth), LIP-0023 (Witness
   construction), LIP-0024 (seal endorsement), LIP-0025 (journal continuity),
   LIP-0014 (re-delegation), LIP-0018, LIP-0019. The v3 bench is named as a
   bench only. Chapter 08 opens with a table that says, for each LIP it
   relies on, who decided what; chapter 14 repeats the status row by row.
2. **A booking is a framework contract plus one minimal contract per grant**
   (book's proposal on LIP-0017 section 5). The rental contract carries the
   human terms, price, payment schedule, manifest hash and the contract seal,
   and names no station or agent key. Each grant binds its own terms object,
   which names the rental contract as its framework. Consequences: effect
   grants bind terms without text (LIP-0006 section 7); a host replacement,
   an image upgrade or a new teammate needs new terms and a new consent, not
   a new rental contract; one spend of the contract seal ends every grant
   under it. v0.1's "replacement contract" is gone.
3. **Five kinds of grant instead of seven.** Rental, member, inter-agent,
   effects (one per slot, several executors with signed partitions: model
   proxy, action service, agent wallet, public action service) and refund.
   All are issued by the landlord's signer, depth 1. Re-delegation is
   described and not used: rows are fixed at issuance, the notary must be a
   third party across owners, and the renter would need a delegation signer
   and a signer for row coins (the coin of a row pays a separate key derived
   from the seed of the re-delegating side's operator signer).
4. **Text and effect.** Effect services refuse a text-bearing grant; the
   landlord, as owner of the executors, does not switch on the
   owner-confirmation exception. A renter's confirmation of one operation
   (landing into a protected branch, a payment above a threshold) is a typed
   limit, "owner-confirmation threshold", with the renter named as the
   confirming owner by the rental action profile.
5. **Consent.** v4 consent is single-use, bound to contract, issuer and
   recipient, at most 72 hours old when the signer starts the issuance. The
   booking hold is therefore always shorter than 72 hours; a failed
   issuance, a host replacement and a renewal each need a fresh consent;
   after a loss of the signer's consent journal, renters in flight consent
   again.
6. **Requests are signed invocations.** On v4 a renter's message carries a
   signed invocation with a salted content hash (LIP-0011 section 7). A
   browser extension that signs only Nostr events cannot sign it, so the
   book introduces the rental client that holds the renter's request key.
   This is open question 2 below.
7. **Payments chapter (new chapter 09), BTC, LTC and BCH only.** Price per
   period in US dollar cents; one coin per contract; a payment address per
   period listed in the contract; invoices computed from signed fields and
   capped by an invoice ceiling in atoms; crediting by confirmation depth
   (effective minimum = max of contract minimum and operator floor); outputs
   to one invoice address add up; a contract balance for over-payment,
   duplicate and partial payment; suspension and a grace term; payment loss
   after crediting per LIP-0008 section 2.2; refunds in the same coin, in
   the atoms actually credited, executed by a per-coin refund wallet under a
   refund grant that the contract seal does not close. NMC is not a payment
   coin; the landlord pays Namecoin fees.
8. **Owner's answers applied as decisions.** A tenant host is a virtual
   machine, a dedicated server or the landlord's own physical machine, and
   the service treats them alike; public work under the landlord's account
   is an offered option; the landlord's model key comes first, the renter's
   own token later; the leak-hold question stays open with a recommendation.
9. **Catalog signing.** Catalog records and review decisions are sections
   signed by configuration statements under the landlord's grant key
   (LIP-0015 section 3); the common catalog is published as a certificate
   set with an anchored head (LIP-0016); a renter's private records are
   delivered directly with short terms, because one issuer has one public
   head. The separate "review key" of v0.1 is gone: the key registry closes
   the list of what the grant key signs.
10. **Key map.** Chapter 10 takes the four danger levels of KEY-REGISTRY,
    maps every registry key the service operates, and lists in a second
    table the rental keys and outside secrets the registry does not name,
    with a "who is hit" column (all renters or one).
11. **Operations.** A runbook for the landlord's name under the v4 name
    rule (what each name operation does to all grants), the refund float,
    payment nodes, and the 60 and 90 minute freshness stops as refusals
    without closure.
12. **Structure.** One new chapter (09, payments); the later chapters moved
    down by one. Nine scenarios, all on v4 and coin payments.

## Open questions for Ivan

At most five, each with the book's recommendation (chapter 13, rows 83 to
87).

1. **Who lifts a leak hold on a renter's credential?** Recommendation: only
   the renter, by a signed request, with rotation as the main path; the
   landlord's operator has no such action. A hold on a token that belongs to
   the landlord (invited account) is lifted by the landlord.
2. **What signs the renter's v4 requests?** An invocation is a typed object
   and a browser extension cannot sign it. Recommendation: the rental client
   (web page or program) holds a request key of its own and the rental grant
   is issued to that key; a renter with a name takes the by-name mode and
   rotates the request key itself; the personal key service comes later.
3. **Refunds and depth.** Recommendation: refunds in coins, the same atoms
   that were credited, without a person, by the refund wallet under the
   refund grant; the transfer fee is paid by the side that caused the end.
   Starting depth floors: 2, 12, 12 blocks (BTC, LTC, BCH) for one period,
   6, 24, 24 for prepayment of several periods. The numbers are provisional.
4. **Default clause of the contract seal.** Recommendation: "issuer only" at
   launch (the renter needs only the rental client, and a booking does not
   wait for a block); "either party" becomes a choice once a renter client
   can spend the seal.
5. **Public work: one landlord account for all renters, or one per renter?**
   Recommendation: one account at launch with low ceilings and the
   moderator; a pool of accounts where hosting terms allow it.

Further questions are rows 88 to 94 of chapter 13; the first of them needs
both specification owners: whether a booking may be a framework contract
with a terms object per grant.

## Gap list delta

Chapter 13 now has 82 numbered deltas and 12 questions (94 rows). v0.1 had
71 deltas and 10 questions.

**Answered by specification 0.1.43 (each a Draft; the residue stays as a
row):**

| v0.1 row | Answer | Residue in v0.2 |
| --- | --- | --- |
| 2, manifest hash in the contract | LIP-0017 sections 1 and 8 | row 3, manifest bytes |
| 5, framework contract and window containment | LIP-0017 section 5 | row 1 |
| 6, contract seal, verdict reference | LIP-0017 section 6 | row 6, scripts, statement bytes, closure record |
| 13, request bytes for a verdict | LIP-0011 section 7 | row 2, invocation members |
| 14, limit-kind registry | LIP-0018 section 2, LIP-0008 section 2 | row 9, no registry, no type profile |
| 17, normative text rule | LIP-0006 section 7 | row 8, refusal code, transport-service profile |
| 19, consent for service-held keys | LIP-0013 section 3.6 | row 20, written for the v3 consent |
| 22, receipt keys | LIP-0008 section 4 | row 15, receipt members and delivery |
| 23, statement kinds | LIP-0015 section 3 | rows 16 and 17 |
| 27, delivery by hash | LIP-0019 | row 18, v4 presentation, retention |
| 28, model executor in the grant | LIP-0008 section 4 | row 19, the proxy's own observation |
| status row, danger levels | KEY-REGISTRY | row 22, entries for rental keys |

**Removed by the owner's decisions:** v0.1 questions 72 (VM or physical),
73 (public work at launch), 75 (default model key), 78 (payment methods).

**Removed by redesign:** v0.1 rows 3 (`profile_sha256`, now part of the
manifest), 16 (money terms object, now the coins limit kind), 18 (member
grants, now member terms under the framework contract), 26 (replacement
contract, now new terms under the same rental contract).

**New in v0.2:**

- v4 objects: members of the grant, invocation and receipt (2); consent for
  a contract without a grant (5); renter requests and the confirmation
  command (7); transport-service profile and refusal code (8);
  owner-confirmation threshold profile (10); agent action table and frame
  on v4 (12); the key holder's permission list for v4 consent (20); key
  registry entries for rental keys (22); the v4 rental exchange (24).
- Issuance and verification (25 to 33): the signer's consent journal store,
  seal account custody and linkage keys, a stock of contract seals,
  observation for tenant-host services, action classes, the three
  provisional numbers, the landlord's name tool, the fate of live v3 grants,
  a checker and a second implementation for the v4 vectors.
- Payments (34 to 44): payment profiles for BTC, LTC and BCH; a second
  chain pin for BCH (it shares the genesis block with BTC); depth tiers;
  the wait `N` after a reorganisation; period terms; invoice, credit and
  balance records; refund terms and grant; refund wallets as grant-gated
  services; payment observation; the rate source; mainnet.
- Platform and service parts: wiping and firmware checks before a physical
  machine returns to the pool (55); a loader with a trust-root pin in
  Curator (74); the rental client (75); the v4 booking service (79).

## What I could not do or verify

- One independent reviewer agent fact-checked chapters 08 and 09 and the v4
  status table of chapter 14 against the specification: no statement that
  contradicts its source and no invented identifier; 6 major findings
  (status, attribution, one internal contradiction about which grant terms
  give force to the contract's text) and 12 minor ones. All 18 are applied.
  The other chapters were checked by the author only: the hygiene check, a
  script that resolves every internal chapter and section reference, and
  spot checks of cited sections. The fixes were not reviewed a second time.
- The rule that settles which grants under a framework contract are
  text-bearing is this book's proposal (the access, member and inter-agent
  terms name the hash of the contract's text; the effects and refund terms
  do not). The specification does not say what a framework contract with a
  text does to the grants under it; it is question 88 of chapter 13.
- The digests of the specification in `.temp/research/v2/` were written by
  sub-agents. I read LIP-0008, LIP-0017, LIP-0018 and the Link book chapters
  on the contract, the grant (section "Версия 4") and rental myself; LIP-0014
  and LIP-0020 to LIP-0025 I know through the digests and targeted reads.
- Facts about the three payment chains (block interval, address formats,
  replacement of unconfirmed transactions, the shared genesis of BTC and
  BCH, the MWEB extension block of LTC) come from general knowledge of their
  public documentation, not from a source in the context tree. The chapter
  says so and defers to qualification of each payment profile.
- The depth floors and every number in the scenarios are illustrative
  starting values. The book names no prices.
- The brief says "v3 is deprecated and unsupported once v4 is released".
  The specification says something narrower (LIP-0008 section 1: v3 frozen,
  new grants on v4 once v4 is qualified, v3 kept for verification; the fate
  of live v3 grants not decided). The book records the owner's decision for
  the service and quotes the specification's wording beside it.
- "The first v4 limit kinds are coins and model cost" is taken from the
  brief as an owner decision of 2026-11-14; the specification names the
  kinds and does not record which come first. Chapter 14 marks it so.
- The Link book (release candidate 4) covers the specification up to 0.1.36;
  LIP-0020 to LIP-0025 are cited from the specification only.
- Only the journey figure was redrawn. No English translation.
