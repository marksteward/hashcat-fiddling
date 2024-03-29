/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

#define NEW_SIMD_CODE

#include "inc_vendor.cl"
#include "inc_hash_constants.h"
#include "inc_hash_functions.cl"
#include "inc_types.cl"
#include "inc_common.cl"
#include "inc_simd.cl"
#include "inc_hash_sha512.cl"

__kernel void m01720_mxx (KERN_ATTR_VECTOR ())
{
  /**
   * modifier
   */

  const u64 lid = get_local_id (0);
  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  /**
   * base
   */

  const u32 pw_len = pws[gid].pw_len;

  u32x w[64] = { 0 };

  for (int i = 0, idx = 0; i < pw_len; i += 4, idx += 1)
  {
    w[idx] = pws[gid].i[idx];
  }

  const u32 salt_len = salt_bufs[salt_pos].salt_len;

  u32x s[64] = { 0 };

  for (int i = 0, idx = 0; i < salt_len; i += 4, idx += 1)
  {
    s[idx] = swap32_S (salt_bufs[salt_pos].salt_buf[idx]);
  }

  sha512_ctx_t ctx0;

  sha512_init (&ctx0);

  sha512_update_global_swap (&ctx0, salt_bufs[salt_pos].salt_buf, salt_bufs[salt_pos].salt_len);

  /**
   * loop
   */

  u32x w0l = w[0];

  for (u32 il_pos = 0; il_pos < il_cnt; il_pos += VECT_SIZE)
  {
    const u32x w0r = words_buf_r[il_pos / VECT_SIZE];

    const u32x w0 = w0l | w0r;

    w[0] = w0;

    sha512_ctx_vector_t ctx;

    sha512_init_vector_from_scalar (&ctx, &ctx0);

    sha512_update_vector (&ctx, w, pw_len);

    sha512_update_vector (&ctx, s, salt_len);

    sha512_final_vector (&ctx);

    const u32x r0 = l32_from_64 (ctx.h[7]);
    const u32x r1 = h32_from_64 (ctx.h[7]);
    const u32x r2 = l32_from_64 (ctx.h[3]);
    const u32x r3 = h32_from_64 (ctx.h[3]);

    COMPARE_M_SIMD (r0, r1, r2, r3);
  }
}

__kernel void m01720_sxx (KERN_ATTR_VECTOR ())
{
  /**
   * modifier
   */

  const u64 lid = get_local_id (0);
  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  /**
   * digest
   */

  const u32 search[4] =
  {
    digests_buf[digests_offset].digest_buf[DGST_R0],
    digests_buf[digests_offset].digest_buf[DGST_R1],
    digests_buf[digests_offset].digest_buf[DGST_R2],
    digests_buf[digests_offset].digest_buf[DGST_R3]
  };

  /**
   * base
   */

  const u32 pw_len = pws[gid].pw_len;

  u32x w[64] = { 0 };

  for (int i = 0, idx = 0; i < pw_len; i += 4, idx += 1)
  {
    w[idx] = pws[gid].i[idx];
  }

  const u32 salt_len = salt_bufs[salt_pos].salt_len;

  u32x s[64] = { 0 };

  for (int i = 0, idx = 0; i < salt_len; i += 4, idx += 1)
  {
    s[idx] = swap32_S (salt_bufs[salt_pos].salt_buf[idx]);
  }

  sha512_ctx_t ctx0;

  sha512_init (&ctx0);

  sha512_update_global_swap (&ctx0, salt_bufs[salt_pos].salt_buf, salt_bufs[salt_pos].salt_len);

  /**
   * loop
   */

  u32x w0l = w[0];

  for (u32 il_pos = 0; il_pos < il_cnt; il_pos += VECT_SIZE)
  {
    const u32x w0r = words_buf_r[il_pos / VECT_SIZE];

    const u32x w0 = w0l | w0r;

    w[0] = w0;

    sha512_ctx_vector_t ctx;

    sha512_init_vector_from_scalar (&ctx, &ctx0);

    sha512_update_vector (&ctx, w, pw_len);

    sha512_update_vector (&ctx, s, salt_len);

    sha512_final_vector (&ctx);

    const u32x r0 = l32_from_64 (ctx.h[7]);
    const u32x r1 = h32_from_64 (ctx.h[7]);
    const u32x r2 = l32_from_64 (ctx.h[3]);
    const u32x r3 = h32_from_64 (ctx.h[3]);

    COMPARE_S_SIMD (r0, r1, r2, r3);
  }
}
