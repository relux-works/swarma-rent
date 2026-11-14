# Swarma Rent, draft 0.1: notes for the lead

First iteration of the research task T15 (rental service on the Swarma
platform and Swarma Link). The book is in `book/ru/` (14 chapters, Russian is
the source of truth) and builds to `book/swarma-rent.ru.pdf`. This file is a
working summary; it is not part of the book.

## What the book claims

A self-sufficient rental service means three things (chapter 00): a renter
goes from terms to finished work and a removal record with no person on the
landlord side in the normal path; each party can check what was agreed and
what happened without the other's server; every function the rental needs has
a named owning service and a described refusal.

The book follows one reading rule: a statement with a citation (Link book,
platform book, LIP section) is taken from that source; a statement without a
citation is a proposal of this book. Status lives only in chapter 13; the gap
list is chapter 12.

## Main design choices

1. **Two groups of services.** Shared landlord services (exchange gateway,
   booking, catalog and review, signer, grant store, placement, refund wallet,
   public action service, status, nodes, relay) hold no renter secret and see
   no renter work content. Everything that sees the renter's messages, code or
   tokens runs on the tenant host: host gateway, slots, launcher, model proxy,
   broker, credential gateway, action service, agent wallet, a2a daemon.
   Two stated exceptions: review of a renter's custom package, and texts the
   agent publishes under the landlord's public account.
2. **Multi-tenancy by multi-instance.** There is no multi-tenant broker. Each
   tenant host has its own broker, credential gateway and action service
   (LIP-0006 section 1 binds one instance to one peer UID and one grantee key).
3. **The rental gateway is split.** The pre-grant exchange stays shared; the
   message path moves to the tenant host with a per-slot station (name and
   message key generated on that host). Station names come from a pool that is
   re-keyed in batches at pool refill, so the cold name-owner key is not used
   per booking.
4. **Placement.** One renter per host, always. Default: one VM with a slot per
   agent (OS-user boundary between agents of one renter). Separate VM per agent
   when the agent reads untrusted input, needs secrets the others must never
   reach, needs guaranteed resources or another platform, or the renter's rules
   demand a kernel boundary between roles. Both mix in one booking.
5. **Manifest** (T16): two lists, agents (per slot: environment and model,
   role profile by lock hash, extra skills by content hash, review reference,
   systems it may use) and allowed systems (adapter, class, targets,
   operations, account model, credential kind). Limits, price, term and
   payees stay in the contract and grants. Proposal: `profile_sha256` means the
   Curator profile lock hash.
6. **Slot launcher** (T16+, T19): nine ordered hash checks, a read-only
   snapshot of the home, a context of four parts (landlord root profile with
   the standing rule only, role profile and skills, contract template text,
   grant terms rendered as instructions), and a signed launch record that is
   an operator claim, not proof of execution.
7. **Catalog and review.** The catalog is a signed statement set with an
   anchored head (LIP-0015/0016 direction, D15). A custom package goes through
   submission, Curator strict audit, a programmatic boundary check (seven
   rules), a text review and a decision bound to the package hash. Any byte
   change is a new submission. Review protects third parties, the landlord's
   model account and the renter; boundaries are held by mechanisms, not by
   review.
8. **Renter credentials.** Enrolment happens after provisioning: the renter's
   browser encrypts the token to the host broker's intake key (attested by a
   statement under the grant key), shared services carry ciphertext only, the
   broker accepts only a renter-signed request for a system named in the
   manifest. Use only through the credential gateway (reads) and the action
   service (every write, by fields). A leak hold is lifted only by the renter.
   At the end: vendor-side revocation where the adapter can, store destroyed,
   host destroyed, a removal record (a claim), and the renter revokes at the
   vendor.
9. **Account models.** Recommended: the renter's own GitHub App or GitLab
   project/group token, enrolled at the tenant host broker. A landlord account
   invited to the renter's org only as one account per renter. Public work
   under the landlord's account goes through the shared public action service
   with five restrictions (named repos, fork flow, content check before
   publication, rate limits with an operator ceiling, acceptance by the
   maintainers). A landlord multi-tenant App is not recommended: its key is a
   cross-tenant secret.
10. **Grants per booking** (T18): rental grant (`deliver`, text through
    contract), member grants, money grant (fields only), write grant for
    allowed systems (fields only), refund grant. A within-cap payment to an
    allow-listed payee ordered by a compromised agent is by design, not a
    bypass; the renter sizes lists and caps accordingly.
11. **Money.** Prepay each period, so each side risks one period. Suspension
    on non-payment is a contract-defined state of the services, then a seal
    spend after the grace term. Refunds are executed by a refund wallet under
    a grant whose only payee is the contract's refund address.
12. **Ending.** Window end; contract seal (T21) with "issuer only" as the
    default clause and the renter's signed termination statement; violation per
    LIP-0011; the renter's own exits that need no landlord: stop paying, revoke
    own tokens.
13. **What stays trusted.** The landlord as host administrator can read
    everything on the tenant host. The book says so and limits it by narrow
    tokens, short periods, the renter's own exits and an operator access
    journal (no standing human login to tenant hosts).

## Open questions for Ivan

The five that change the design most:

1. Is a VM on a shared hypervisor a "fully separate host", or must renters be
   on separate physical machines? The book offers both classes with the VM as
   default.
2. Public work under our account: allowed at launch at all? One account or an
   account per renter? The account's reputation is shared between renters.
3. Whose model by default: our API key per host (theft bypasses slot limits)
   or the renter's own key through the credential gateway? Which provider
   terms apply to renting out access? The book excludes personal subscriptions.
4. Who lifts a leak hold on a renter's credential? The book says the renter
   only; the platform rule says "the owner", which on a tenant host is
   ambiguous.
5. Payment rails and refunds: NMC/BTC/LTC only (regtest profiles today) or a
   company rail as well; are refunds automatic through the refund wallet?

Further questions are rows 59-68 of chapter 12: the landlord multi-tenant App,
who signs acceptance of a custom package and whether custom skills may carry
built commands, how "one renter" is defined for an organization with several
keys, grounds for operator login to a tenant host, the default clause of the
contract seal.

One more that is not in the book: the title page lists both authors in the
order of the other books. Confirm or change.

## Gap list

Chapter 12 has 58 numbered deltas with their sources. By target:

- Link spec (1-23): a v4 rental contract profile with bytes; manifest hash
  field and manifest canonical bytes; multi-slot and framework contracts; the
  contract seal and a renter termination statement; period terms and
  suspension; refund terms and signed records; moderation fields and request
  bytes for NIP-17 messages; a limit-kind registry; an action profile for code
  hosting; a published money terms profile; the normative "effect services
  refuse text-bearing grants" rule; member grants; statement kinds for the
  catalog, review, intake key and host key; signer revoke reasons; `slot.station`
  profile; a replacement contract after host loss; delivery by hash.
- Platform, credentials (24-33): the broker contract extension for service
  principals; booking scope; renter-side enrolment; hold ownership; removal at
  the end; credential gateway and action service; GitLab/GitHub adapters; the
  rental action set without board acceptance; service classes beyond model
  providers and code hosting; harness qualification with a placeholder.
- Platform, placement and launch (34-44): placement service; sealed host
  image and policy derived from the manifest; the slot service on Linux; the
  slot launcher; the key-holder gate; host gateway and a renter stop command;
  the station name pool; node access for host services; operator access
  journal; messages between a renter's agents; hardware attestation.
- Swarma Curator (45-52): a catalog; a submission and review path with a
  boundary-rule checker; audit of instruction text and a released audit
  registry; the snapshot command; building skill commands at profile install;
  one lock for root profile plus role profile plus renter skills; working-tree
  instruction exclusion; a link from Curator trust to the Link trust root.
- New service parts (53-58): the web interface; status service; refund wallet;
  public action service; mainnet payments; contract templates and privacy
  notice.

## What I could not do or verify

- Vendor facts about GitHub and GitLab in chapter 07 are from general
  knowledge of their public documentation, not from a source in the context
  tree. The chapter says so and defers to adapter qualification. They need a
  check before publication.
- The money grant fields in chapter 08 follow the demo payment executor as
  described in the QA matrix; I described them in words and did not quote the
  frozen field names or refusal codes, because the freeze amendment was open.
- Figures are drawn with the Swarma diagram kit vendored into
  `scripts/diagram-kit/`; `test_render.py` and the kit's fixtures are not
  vendored.
- No English translation.
- The review pass was done by two independent reviewer agents against the
  sources; no human has read the text.
