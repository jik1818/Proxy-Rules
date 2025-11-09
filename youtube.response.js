if ($response.body) {
  let body = $response.body;

  // 移除广告字段
  body = body.replace(/"adPlacements":

\[[^\]

]*\]

/g, '"adPlacements":[]');
  body = body.replace(/"playerAds":

\[[^\]

]*\]

/g, '"playerAds":[]');
  body = body.replace(/"adBreaks":

\[[^\]

]*\]

/g, '"adBreaks":[]');
  body = body.replace(/"adSlots":

\[[^\]

]*\]

/g, '"adSlots":[]');

  $done({ body });
} else {
  $done({});
}
