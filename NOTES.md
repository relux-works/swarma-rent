# Swarma Rent, draft 0.1: notes for the lead

First iteration of the research task T15 (rental service on the Swarma
platform and Swarma Link). The book is in `book/ru/` (14 chapters, Russian is
the source of truth) and builds to `book/swarma-rent.ru.pdf` (91 pages). This
file is a working summary; it is not part of the book.

## What the book claims

A self-sufficient rental service means three things (chapter 00): a renter
goes from terms to finished work and a removal record with no person on the
landlord side in the normal path; each party can check what was agreed, when a
grant was issued and when it ended without the other's server; every function
the rental needs has a named owning service and a described refusal.

The book follows one reading rule: a statement with a citation (Link book
0.6, platform book 2.0, Link spec 0.1.27, Swarma Curator docs 0.15.0-rc.9) is
taken from that source; a statement without a citation is a proposal of this
book. Status lives only in chapter 13; the gap list is chapter 12.

The decisions of 14 November 2026 are written as decisions of ONE owner. The
status vocabulary of chapter 13 has a separate status, "решено одним
владельцем", for them; where such a decision changes a LIP the book says the
co-author's agreement is pending. The rule "different renters on separate
hosts" is written as the platform owner's requirement to the service, not as a
specification decision.

## Main design choices

1. **Two groups of services.** Shared landlord services (exchange gateway,
   booking, catalog and review, signer, grant store, placement, refund wallet,
   public action service, status, support agent, nodes, relay) hold no renter
   secret and see no renter work content. Everything that sees the renter's
   messages, code or tokens runs on the tenant host: host gateway, slot
   manager and launcher, key holder, model proxy, broker, credential gateway,
   action service, agent wallet, a2a daemon. Two stated exceptions: review of
   a renter's custom package, and texts the agent publishes under the
   landlord's public account.
2. **Multi-tenancy by multi-instance.** There is no multi-tenant broker. Each
   tenant host has its own broker, credential gateway and action service.
   LIP-0006 section 1 binds one service instance to one peer UID and one
   grantee key, so one action service serving several agents of one renter
   needs a service-profile extension (gap row 20).
3. **The rental gateway is split.** The pre-grant exchange stays shared; the
   message path moves to the tenant host with one station per slot. Station
   message keys are created when a host enters the pool and are written into
   name values by a separate "station-name owner key", so the cold owner key
   of the landlord's name is not used per pool refill. Agent request keys are
   created at booking. The contract names both keys of every slot, so both
   exist before the renter signs.
4. **Placement.** One renter per host, always. Default: one VM with a slot per
   agent (OS-user boundary between agents of one renter). A separate VM per
   agent when the agent reads untrusted input, needs secrets the others must
   never reach, needs guaranteed resources or another platform, or the
   renter's rules demand a kernel boundary between roles. Both mix in one
   booking. An instance starts on the first message, not at provisioning.
5. **Manifest** (T16): the landlord's root profile record, a list of agents
   (per slot: role profile by lock hash, extra skills by content hash, review
   reference, systems it may use) and a list of allowed systems (adapter,
   class, targets, operations, account model, credential kind). The harness
   and the model of a slot are named by the contract next to the slot label,
   because the owner's decision limits the manifest to profiles, skills and
   systems. Limits, price, term and payees stay in the contract and grants.
   Proposal: `profile_sha256` means the Curator profile lock hash.
6. **Slot launcher** (T16+, T19): nine ordered hash checks, a read-only
   snapshot of the home, a context of four parts (landlord root profile, role
   profile and skills, contract terms text, grant terms rendered as
   instructions), and a signed launch record that carries the composed lock
   hash. The record is an operator claim, not proof of execution. The
   composition of the context was a proposal to the owner, and the book says
   so.
7. **Catalog and review.** The catalog is a signed statement set with an
   anchored head (LIP-0015/0016 direction, D15): one common set plus one set
   per renter with its own head, so a renter's private entries are not visible
   to others. A custom package goes through submission, Curator strict audit,
   a programmatic boundary check (seven rules; six by program, one by the
   reviewer), a text review and a decision bound to the package hash. The
   automated steps run to the end and return the full list of findings; the
   reading review starts only on a package without findings. Any byte change
   is a new submission.
8. **Renter credentials.** Enrolment happens after provisioning: the renter's
   browser encrypts the token to the host broker's intake key (attested by a
   statement under the grant key), shared services carry ciphertext only, the
   broker accepts only a renter-signed request for a system named in the
   manifest. Use only through the credential gateway (reads of model providers
   and code hosting) and the action service (every write, by fields; reads of
   other service classes). A leak hold is lifted only by the renter. One end
   order for every reason of termination (seven steps): credentials are
   revoked and destroyed at once, slot homes stay read-only until the export
   window ends, then the host is destroyed and the renter gets a removal
   record (a claim).
9. **Account models.** Recommended: the renter's own GitHub App or GitLab
   project/group token, enrolled at the tenant host broker. A landlord account
   invited to the renter's organisation only as one account per renter, from a
   pool, with its token enrolled by the placement service. Public work under
   the landlord's account goes through the shared public action service, which
   holds the public account token and the key of the public-text moderator.
   A landlord multi-tenant App is not recommended: its key is a cross-tenant
   secret. Commits are signed by a git signing key that the host key holder
   keeps.
10. **Grants per booking** (T18): seven kinds. Rental, member and inter-agent
    grants are bound to the rental contract (text reaches the agent through
    them). Model, money, write and refund grants each bind their own
    field-only terms object, so no effect service reads text. A within-cap
    payment to an allow-listed payee ordered by a compromised agent is by
    design, not a bypass; the renter sizes lists and caps accordingly.
11. **Money.** Prepay each period, so each side risks one period; a renter may
    prepay several. The contract fixes the price per period in dollar cents,
    the coin, one payment address and the rate rule, so a period invoice is
    computed from signed fields and needs no new consent. Suspension on
    non-payment is a contract-defined state of the services, then a seal spend
    after the grace term. Refunds are executed by a refund wallet under a
    refund grant whose only payee is the contract's refund address and whose
    limit is the price of the whole term. The refund grant has its own seal
    outside the contract seal and outlives the rental.
12. **Ending.** Eight events with a refund rule each (chapter 08, "Конец
    аренды и возврат"). Contract seal (T21) with "issuer only" as the default
    clause and the renter's signed termination statement; violation per
    LIP-0011 (the rental grant's seal carries the verdict reference, then the
    contract seal closes the rest); the renter's own exits that need no
    landlord: stop paying, revoke own tokens. A lost host or a move to a new
    image goes through a replacement contract that the renter signs, or
    through spare stations named in advance with their keys.
13. **What stays trusted.** The landlord as host administrator can read
    everything on the tenant host. The book says so and limits it by narrow
    tokens, short periods, the renter's own exits and an operator access
    journal. The key map in chapter 09 has 32 rows with a danger level, the
    damage of a theft and the recovery for each.

## Open questions for Ivan

The five that change the design most:

1. Is a VM on a shared hypervisor a "fully separate host", or must renters be
   on separate physical machines? The book offers both classes with the VM as
   default.
2. Public work under our account: allowed at launch at all? The book builds it
   on one account shared by renters, so its reputation is shared; an account
   per renter removes that and needs an account pool.
3. Whose model by default: our API key per host (theft bypasses slot limits)
   or the renter's own key through the credential gateway? Which provider
   terms apply to renting out access?
4. Who lifts a leak hold on a renter's credential? The book says the renter
   only; the platform rule says "the owner", which on a tenant host is
   ambiguous.
5. Payment rails and refunds: NMC/BTC/LTC only (regtest profiles today) or a
   company rail as well; are refunds automatic through the refund wallet? The
   only wallet type in the spec is `wallet.nmc`.

Further questions are rows 72-81 of chapter 12: the landlord multi-tenant App,
who signs acceptance of a custom package and whether custom skills may carry
built commands, how "one renter" is defined for an organisation with several
keys, grounds for operator login to a tenant host, the default clause of the
contract seal.

Three more that are not rows of the book:

- The title page lists both authors in the order of the other books. Confirm
  or change.
- The book treats the 14 November decisions as one owner's. If the co-author
  has agreed since, chapter 13 and the bases in chapter 12 can be raised.
- Building and testing the renter's code inside the slot departs from the
  platform rule that puts builds on separate runners without secrets (gap row
  45). The book states the departure; it needs the owner's decision.

## Gap list

Chapter 12 has 71 numbered deltas with their bases and 10 questions. By
target:

- Link spec (1-30): a v4 rental contract profile with bytes; manifest hash
  field and manifest canonical bytes; multi-slot and framework contracts; the
  contract seal and a renter termination statement; period terms and
  suspension; refund terms, the refund grant and a refund wallet for BTC and
  LTC; moderation fields and request bytes for NIP-17 messages; a limit-kind
  registry; an action profile for code hosting; a published money terms
  profile; the normative "effect services refuse text-bearing grants" rule;
  member, model and inter-agent grants and the consent for grants issued to
  service-held keys; a service profile for several agents per instance;
  journal capacity over a term; receipt delivery to the renter; statement
  kinds for the catalog, review, intake key and host key; signer revoke
  reasons; the `slot.station` profile; a replacement contract; delivery by
  hash; chain checks in the model proxy and a per-period proxy token; the git
  signing key statement.
- Platform, credentials (31-41): the broker contract extension for service
  principals; booking scope; renter-side enrolment; enrolment of a
  landlord-owned token; hold ownership; removal at the end; credential gateway
  and action service; GitLab/GitHub adapters; the rental action set without
  board acceptance; service classes beyond model providers and code hosting;
  harness qualification with a placeholder.
- Platform, placement and launch (42-55): placement service; sealed host
  image and policy derived from the manifest; the slot service on Linux;
  builds and tests in the slot; the slot launcher; the key-holder gate; host
  gateway, host stop and a renter stop command; the moderating model; the
  station name pool; node access for host services; the disk encryption key;
  operator access journal; messages between a renter's agents; hardware
  attestation.
- Swarma Curator (56-63): a catalog with a common set and per-renter sets; a
  submission and review path with a boundary-rule checker; audit of
  instruction text and a released audit registry; the snapshot command;
  building skill commands at profile install; one lock for root profile plus
  role profile plus renter skills; working-tree instruction exclusion; a link
  from Curator trust to the Link trust root.
- New service parts (64-71): the web interface; status service; support
  agent; refund wallet; a renter wallet able to spend a one-of-two contract
  seal; public action service; mainnet payments; contract templates and
  privacy notice.

## Review

Two independent reviewer agents read the first draft against the sources
(chapters 00-06 and 07-13). Their findings were applied before this commit.
The blockers were statements above their source: decisions of one owner
written as decisions of both, and LIP-0015/0016 described as finished. The
major findings changed the design in these places: the end-of-rental order,
the moment station keys are created, the manifest (harness and model moved to
the contract, the root profile pinned), private catalog entries in a public
set, the refund grant being closed by the contract seal, the grants table, the
key map, the period of the non-payment scenario. The fixes themselves were not
reviewed a second time.

## What I could not do or verify

- No human has read the text. The review pass was done by agents.
- Vendor facts about GitHub and GitLab in chapter 07 are from general
  knowledge of their public documentation, not from a source in the context
  tree. The chapter says so and defers to adapter qualification. They need a
  check before publication.
- The money grant fields in chapter 08 are a proposal of the book written in
  words. I did not quote field names or refusal codes of the demo payment
  executor, because no citable source states them.
- Figures are drawn with the Swarma diagram kit vendored into
  `scripts/diagram-kit/`; `test_render.py` and the kit's fixtures are not
  vendored.
- No English translation.
- Numbers in the scenarios (terms, periods, grace terms, limits) are
  illustrative. The book names no prices.
